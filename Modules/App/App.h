#pragma once

#include "d3dApp.h"

class App : public D3DApp
{
public:
	App(HINSTANCE instance);
	virtual void Debug() override;
	virtual bool Initialize() override;
protected:
	void Update(const GameTimer& gt) override;
	void Draw(const GameTimer& gt) override;
private:

};