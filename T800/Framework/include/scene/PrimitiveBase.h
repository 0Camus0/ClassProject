/*********************************************************
* Copyright (C) 2017 Daniel Enriquez (camus_mm@hotmail.com)
* All Rights Reserved
*
* You may use, distribute and modify this code under the
* following terms:
* ** Do not claim that you wrote this software
* ** A mention would be appreciated but not needed
* ** I do not and will not provide support, this software is "as is"
* ** Enjoy, learn and share.
*********************************************************/

#ifndef T800_PRIMITIVEBASE_H
#define T800_PRIMITIVEBASE_H

#include <Config.h>

#include <scene/SceneProp.h>
#include <video/BaseDriver.h>

#include <vector>

#ifndef BUFFER_OFFSET
#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#endif

class PrimitiveBase {
public:
	PrimitiveBase() : pScProp(0) , gSig(0) {
		for(int i=0;i<8;i++){
			Textures[i]=0;
		}
		EnvMap = 0;
	}
	virtual ~PrimitiveBase(){}
	virtual void Create() = 0;
	virtual void Create(char *) = 0;
	virtual void Transform(float *t) = 0;
	virtual void Draw(float *t,float *vp) = 0;
	virtual void Destroy() = 0;

	void SetGlobalSignature(unsigned int f){ gSig = f; }
	void SetTexture(Texture* tex,int index){
		Textures[index] = tex;
	}

	void SetEnvironmentMap(Texture* tex) {
		EnvMap = tex;
	}

	void SetSceneProps(SceneProps *p) { pScProp = p; }
	SceneProps				*pScProp;
	Texture*				 Textures[8];
	Texture*			     EnvMap;
	unsigned int gSig;
};


#endif
