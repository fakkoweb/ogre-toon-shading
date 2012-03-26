inline void Console::scroll(const OIS::KeyCode& iKeyCode)
{
	switch (iKeyCode)
	{
	case OIS::KC_PGUP:
		if (mStartline > 0)
			mStartline--;
		break;
	case OIS::KC_PGDOWN:
		if (mStartline < mLines.size())
			mStartline++;
		break;
	}
	mUpdateConsole = true;
}

inline void Console::back()
{
	if (mPrompt.size())
		mPrompt.erase(mPrompt.end() - 1);
	mUpdatePrompt = true;
}

inline void Console::setActive(const bool iActive)
{
	mLayer->setVisible(mActive = iActive);
	mPrompt = "";
}

inline bool Console::getActive() const
{
	return mActive;
}

inline void Console::readCommand(const OIS::KeyEvent& iKeyEvent)
{
	if (LEGAL_CHARS.find(static_cast<char>(iKeyEvent.text)))
		mPrompt += static_cast<char>(iKeyEvent.text);
	mUpdatePrompt = true;
}

inline void Console::clear()
{
	mLines.clear();
}

inline void Console::commandList()
{
	for (auto cIt = mCommands.cbegin(); cIt != mCommands.cend(); ++cIt)
	{
		print(cIt->first);
	}
}

inline void Console::ogreLog(const Ogre::StringVector& iVector)
{
	if (iVector.size() == 2)
	{
		Ogre::String parameter = iVector[1];
		Ogre::StringUtil::toLowerCase(parameter);

		if (parameter == "on")
			mOgreLog = true;
		else if (parameter == "off")
			mOgreLog = false;
	}
	else
	{
		print("Usage: ogrelog <on-off>");
	}
}