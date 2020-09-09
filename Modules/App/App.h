#pragma once

#include "d3dApp.h"
#include "../Common/Common.h"
struct RenderItem;

GRPAppBegin

class App : public D3DApp
{
public:
	App(HINSTANCE instance);
	~App();
	virtual void Debug() override;
	virtual bool Initialize() override;
protected:
	void Update(const GameTimer& gt) override;
	void Draw(const GameTimer& gt) override;
	void LoadScene();
	virtual void OnMouseDown(WPARAM btnState, int x, int y);
	virtual void OnMouseUp(WPARAM btnState, int x, int y);
	virtual void OnMouseMove(WPARAM btnState, int x, int y);
private:
	const std::string m_scene_path = "../Resources/City/Fbx.FBX";
	POINT mLastMousePos;

	std::vector<RenderItem*> m_loaded_render_items;
};

GRPAppEnd