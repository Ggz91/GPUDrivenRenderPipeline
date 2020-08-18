#pragma once

#include "d3dApp.h"
#include "../Common/Common.h"
struct RenderItem;

GRPAppBegin

class App : public D3DApp
{
public:
	App(HINSTANCE instance);
	virtual void Debug() override;
	virtual bool Initialize() override;
protected:
	void Update(const GameTimer& gt) override;
	void Draw(const GameTimer& gt) override;
	void LoadScene();
private:
	const std::string m_scene_path = "../Resources/City/Fbx.FBX";
};

GRPAppEnd