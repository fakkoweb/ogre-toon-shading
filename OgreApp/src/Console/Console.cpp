#include <preheader.h>
#include "Console.h"
#include "Gui.h"

using namespace Ogre;

#if OGRE_VERSION_MAJOR == 1 && OGRE_VERSION_MINOR == 7
template<> Console* Singleton<Console>::ms_Singleton = 0;
#else
template<> Console* Singleton<Console>::msSingleton = 0;
#endif

const String Console::LEGAL_CHARS = String("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890+!\"'#%&/()=?[]\\*-_.:,; ");

Console::Console()
	:mScreen(nullptr)
	,mLayer(nullptr)
	,mPromptText(nullptr)
	,mConsoleText(nullptr)
	,mDecoration(nullptr)
	,mGlyphData(nullptr)
	,mActive(true)
	,mInitialised(false)
	,mUpdateConsole(false)
	,mUpdatePrompt(false)
	,mOgreLog(false)
	,mStartline(0)
	,mLines(std::list<String>())
	,mPrompt(String())
	,mCommands(std::map<String, ConsoleFunctionPtr>())
	,mLastCommands(std::list<String>())
	,mLastCommandCalled(std::list<String>::iterator())
{
}
 
Console::~Console()
{
	if (mInitialised)
		shutdown();
}

void Console::init(Gui* const iGui)
{
	if(mInitialised)
		shutdown();

	Root::getSingletonPtr()->addFrameListener(this);
	LogManager::getSingleton().getDefaultLog()->addListener(this);

	mScreen = iGui->getScreen("MainScreen");
	mLayer = iGui->createLayer(mScreen, "ConsoleLayer");
	mGlyphData = mLayer->_getGlyphData(CONSOLE_FONT_INDEX);

	mConsoleText = mLayer->createMarkupText(CONSOLE_FONT_INDEX, 10, 10, StringUtil::BLANK);
	mConsoleText->width(mScreen->getWidth() - 10);
	mPromptText = mLayer->createCaption(CONSOLE_FONT_INDEX, 10, 10, "> _");
	mDecoration = mLayer->createRectangle(8, 8, mScreen->getWidth() - 16, mGlyphData->mLineHeight );
	mDecoration->background_gradient(Gorilla::Gradient_NorthSouth, Gorilla::rgb(128, 128, 128, 128), Gorilla::rgb(64, 64, 64, 128));
	mDecoration->border(2, Gorilla::rgb(128, 128, 128, 128));

	mInitialised = true;
	mLastCommandCalled = mLastCommands.end();

	addCommand("cls", boost::bind(&Console::clear, this));
	addCommand("list", boost::bind(&Console::commandList, this));
	addCommand("ogrelog", boost::bind(&Console::ogreLog, this, _1));

	clear();

	print("%5DJ%R%6Console.%0");
	print("Type list to display all possible commands.");
	print("Use PageUp / PageDown to scroll the window.");
	print("Use arrow keys to recall old commands.");
	print("Use ESC to exit.");
}

void Console::shutdown()
{
	if (!mInitialised)
		return;
 
	mInitialised = false;
 
	Root::getSingletonPtr()->removeFrameListener(this);
	LogManager::getSingleton().getDefaultLog()->removeListener(this);
}

void Console::print(const String& iText)
{
	const char*str = iText.c_str();
	const int len = iText.length();
	String line;
	for (int i = 0; i < len; ++i)
	{
		if (str[i] == '\n' || line.length() >= CONSOLE_LINE_LENGTH)
		{
			mLines.push_back(line);
			line = "";
		}
		if (str[i] != '\n')
			line += str[i];
	}
	if (line.length())
		mLines.push_back(line);
	if (mLines.size() > CONSOLE_LINE_COUNT)
		mStartline = mLines.size() - CONSOLE_LINE_COUNT;
	else
		mStartline = 0;

	mUpdateConsole = true;
}

void Console::addCommand(const String& iCommand, ConsoleFunctionPtr iFunctionPtr)
{
	mCommands[iCommand] = iFunctionPtr;
}

void Console::removeCommand(const String& iCommand)
{
	mCommands.erase(mCommands.find(iCommand));
}

bool Console::frameStarted(const FrameEvent& evt)
{
	if(mUpdateConsole)
		updateConsole();
	
	if (mUpdatePrompt)
		updatePrompt();
	
	return true;
}

bool Console::frameEnded(const FrameEvent &evt)
{
	return true;
}

bool Console::keyPressed(const OIS::KeyEvent& arg)
{
	if (!mActive)
		return true;

	switch (arg.key)
	{
	case OIS::KC_ESCAPE:
		setActive(false);
		break;
	case OIS::KC_RETURN:
		if (!executeCommand())
			print("Invalid command.");
		break;
	case OIS::KC_BACK:
		back();
		break;
	case OIS::KC_PGUP:
	case OIS::KC_PGDOWN:
		scroll(arg.key);
		break;
	case OIS::KC_UP:
		recallPreviousCommand();
		break;
	case OIS::KC_DOWN:
		recallNextCommand();
		break;
	default:
		readCommand(arg);
		break;
	}

	return true;
}

void Console::recallPreviousCommand()
{
	mPrompt.clear();
	if((mLastCommandCalled != mLastCommands.begin()))
	{
		mLastCommandCalled--;
		mPrompt += *(mLastCommandCalled);
		mUpdatePrompt = true;
	}
}

void Console::recallNextCommand()
{
	mPrompt.clear();
	if((mLastCommandCalled != mLastCommands.end()))
	{
		if((*mLastCommandCalled != mLastCommands.back()))
		{
			mLastCommandCalled++;
			mPrompt += *(mLastCommandCalled);
			mUpdatePrompt = true;
		}	
	}
}

bool Console::keyReleased(const OIS::KeyEvent& arg)
{
	if (arg.key == OIS::KC_TAB)
		setActive(true);

	return true;
}

void Console::updateConsole()
{
	mUpdateConsole = false;
 
	std::stringstream text;
	std::list<String>::iterator i,start,end;

	//make sure is in range
	if(mStartline>mLines.size())
		mStartline=mLines.size();

	int lcount=0;
	start=mLines.begin();
	for(size_t c=0;c<mStartline;c++)
		start++;
	end=start;
	for(size_t c=0;c<CONSOLE_LINE_COUNT;c++)
	{
		if(end==mLines.end())
			break;
		end++;
	}

	for(i=start;i!=end;i++)
	{
		lcount++;
		text << (*i) << "\n";
	}
	mConsoleText->text(text.str());
 
	// Move prompt downwards.
	mPromptText->top(10 + (lcount * mGlyphData->mLineHeight));
 
	// Change background height so it covers the text and prompt
	mDecoration->height(((lcount+1) * mGlyphData->mLineHeight) + 4);
 
	mConsoleText->width(mScreen->getWidth() - 20);
	mDecoration->width(mScreen->getWidth() - 16);
	mPromptText->width(mScreen->getWidth() - 20);
}

void Console::updatePrompt()
{
	mUpdatePrompt = false;
	std::stringstream text;
	text << "> " << mPrompt << "_";
	mPromptText->text(text.str());
}

#if OGRE_VERSION_MAJOR == 1 && OGRE_VERSION_MINOR == 7
void Console::messageLogged(const String &message, LogMessageLevel lml, bool maskDebug, const String &logName)
#else
void Console::messageLogged(const String& message, LogMessageLevel lml, bool maskDebug, const String& logName, bool& skip)
#endif
{
	if (mOgreLog)
		print(message);
}

bool Console::executeCommand()
{
	print("%3> " + mPrompt + "%R");

	bool commandExecuted = false;
	const StringVector params = StringUtil::split(mPrompt, " ");
	if (params.size())
	{
		for (auto it = mCommands.begin(); it != mCommands.end(); ++it)
		{
			if((*it).first == params[0])
			{
				if((*it).second)
				{
					(*it).second(params);
					commandExecuted = true;
				}
				break;
			}
		}
		if(mLastCommands.size() > MAXCOMMANDSTORED)
		{
			mLastCommands.pop_front();
		}
		mLastCommands.push_back(mPrompt);
		mLastCommandCalled = mLastCommands.end();
		mPrompt.clear();
		mUpdateConsole = true;
		mUpdatePrompt = true;
	}

	return commandExecuted;
}

bool Console::executeCommand(Ogre::String iCommand)
{
	print("%3> " + iCommand + "%R");

	bool commandExecuted = false;
	const StringVector params = StringUtil::split(iCommand, " ");
	if (params.size())
	{
		for (auto it = mCommands.begin(); it != mCommands.end(); ++it)
		{
			if((*it).first == params[0])
			{
				if((*it).second)
				{
					(*it).second(params);
					commandExecuted = true;
				}
				break;
			}
		}
		if(mLastCommands.size() > MAXCOMMANDSTORED)
		{
			mLastCommands.pop_front();
		}
		mLastCommands.push_back(mPrompt);
		mLastCommandCalled = mLastCommands.end();
		iCommand.clear();
		mUpdateConsole = true;
		mUpdatePrompt = true;
	}

	return commandExecuted;
}