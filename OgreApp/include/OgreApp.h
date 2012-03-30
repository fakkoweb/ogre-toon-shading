/*
-----------------------------------------------------------------------------
Filename:    OgreApp.h
-----------------------------------------------------------------------------


This source file is generated by the
   ___                   _              __    __ _                  _ 
  /___\__ _ _ __ ___    /_\  _ __  _ __/ / /\ \ (_)______ _ _ __ __| |
 //  // _` | '__/ _ \  //_\\| '_ \| '_ \ \/  \/ / |_  / _` | '__/ _` |
/ \_// (_| | | |  __/ /  _  \ |_) | |_) \  /\  /| |/ / (_| | | | (_| |
\___/ \__, |_|  \___| \_/ \_/ .__/| .__/ \/  \/ |_/___\__,_|_|  \__,_|
      |___/                 |_|   |_|                                 
      Ogre 1.7.x Application Wizard for VC10 (July 2011)
      http://code.google.com/p/ogreappwizards/
-----------------------------------------------------------------------------
*/
#ifndef __OgreApp_h_
#define __OgreApp_h_

#include "BaseApplication.h"
#if OGRE_PLATFORM == OGRE_PLATFORM_WIN32
#include "../res/resource.h"
#endif

class OgreApp : public BaseApplication
{
public:

    OgreApp(void);
    virtual ~OgreApp(void);

protected:

	virtual void createScene(void);
	virtual void createFrameListener(void);

	bool frameRenderingQueued(const Ogre::FrameEvent& evt);

	virtual bool keyPressed(const OIS::KeyEvent &arg);

	virtual void sliderMoved(OgreBites::Slider* slider);

	Ogre::SceneNode*		mLightPivot;
	Ogre::Entity*			mHead;

	OgreBites::ParamsPanel* mTechniqueDetail;
	OgreBites::CheckBox*	mMoveLight;

	OgreBites::Slider*		mThicknessSlider;
	OgreBites::Slider*		mThresholdSlider;

	enum Techniques { 
		CELSHADING,  
		SOBEL_FILTER 
	} mCurrentTechnique;

	class SobelListener : public Ogre::CompositorInstance::Listener
	{
	private:

		float mThickness;
		float mThreshold;

	public:

		SobelListener();

		void notifyMaterialRender(Ogre::uint32 pass_id, Ogre::MaterialPtr &mat);

		void setThickness(float thickness);
		float getThickness() const;

		void setThreshold(float threshold);
		float getThreshold() const;
	};

	SobelListener*			mSobelListener;
};

#endif // #ifndef __OgreApp_h_
