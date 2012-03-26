//! \author Andrea Benedetti
//! \date 01 Dicembre 2011

class Gui;

typedef boost::function<void(const Ogre::StringVector&)> ConsoleFunctionPtr;

//! Classe per la gestione della console di debug. La consolle tiene traccia dei comandi eseguiti, che siano corretti o no, 
//! fino ad un numero immagazzinato in MAXCOMMANDSTORED, superato il quale vengono "dimenticati" i comandi più vecchi 
class Console : public Ogre::Singleton<Console>, Ogre::FrameListener, Ogre::LogListener, public OIS::KeyListener
{	
public:
	//! Costruttore.
	Console();
	//! Distruttore.
	~Console();

	//! Inizializzazione.
	//! \param iGui puntatore alla Gui.
	void init(Gui* const iGui);
	//! Shutdown.
	void shutdown();
	
	//! Set dello stato (attivo/disattivo).
	//! \param iVisible stato.
	void setActive(const bool iActive);
	//! Get dello stato (attivo/disattivo).
	//! \return stato.
	bool getActive() const;

	//! Formattazione del testo.
	//! \param iText testo da stampare.
	void print(const Ogre::String& iText);
		
	//! Aggiunge un comando da gestire.
	//! \param iCommand nome del comando.
	//! \param ConsoleFunctionPtr puntatore al comando da eseguire.
	void addCommand(const Ogre::String& iCommand, ConsoleFunctionPtr iFunctionPtr);
	//! Rimuove un comando.
	//! param iCommand nome del comando da rimuovere.
	void removeCommand(const Ogre::String& iCommand);


	//! esecuzione di un comando già bindato.
	//! param iCommand nome del comando da eseguire.
	bool executeCommand(Ogre::String iCommand);

private:
	static const int CONSOLE_FONT_INDEX = 14;
	static const int CONSOLE_LINE_LENGTH = 85;
	static const int CONSOLE_LINE_COUNT = 15;
	static const Ogre::String LEGAL_CHARS;

	//! Overload della funzione frameStarted di Ogre.
	bool frameStarted(const Ogre::FrameEvent& evt);
	//! Overload della funzione frameEnded di Ogre.
	bool frameEnded(const Ogre::FrameEvent& evt);

	//! Overload della funzione keyPressed di OIS.
	bool keyPressed(const OIS::KeyEvent& arg);
	//! Overload della funzione keyReleased di OIS.
	bool keyReleased(const OIS::KeyEvent& arg);

	//! Update della console.
	void updateConsole();
	//! Update del prompt.
	void updatePrompt();
	//! Ricerca e stampa il comando precedente all'ultimo visualizzato
	void recallPreviousCommand();
	//! Ricerca e stampa il comando successivo all'ultimo visualizzato
	void recallNextCommand();

	//! Logger.
#if OGRE_VERSION_MAJOR == 1 && OGRE_VERSION_MINOR == 7
	void messageLogged (const Ogre::String &message, Ogre::LogMessageLevel lml, bool maskDebug, const Ogre::String &logName);
#else
	void messageLogged(const Ogre::String& message, Ogre::LogMessageLevel lml, bool maskDebug, const Ogre::String& logName, bool& skip);
#endif

	//! Parsing ed esecuzione del comando.
	bool executeCommand();

	//! Gestione dello scroll.
	void scroll(const OIS::KeyCode& iKeyCode);
	//! Gestione del back.
	void back();
	//! Lettura del comando:
	void readCommand(const OIS::KeyEvent& iKeyEvent);

	//! Clear.
	void clear();
	//! Lista dei comandi disponibili.
	void commandList();
	//! Attiva/disattiva la visualizzazione del log di OGRE.
	void ogreLog(const Ogre::StringVector& iVector);

	Gorilla::Screen* mScreen;
	Gorilla::Layer* mLayer;
	Gorilla::Caption* mPromptText;
	Gorilla::MarkupText* mConsoleText;
	Gorilla::Rectangle* mDecoration;
	Gorilla::GlyphData* mGlyphData;
	
	bool mActive;
	bool mInitialised;
	
	bool mUpdateConsole;
	bool mUpdatePrompt;
	bool mOgreLog;

	size_t mStartline;
	std::list<Ogre::String> mLines;
	std::list<Ogre::String> mLastCommands;
	std::list<Ogre::String>::iterator mLastCommandCalled;
	Ogre::String mPrompt;
	std::map<Ogre::String, ConsoleFunctionPtr> mCommands;

	static const int MAXCOMMANDSTORED = 10;
};

#include "Console.inl"