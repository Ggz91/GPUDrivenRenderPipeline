#include "LoggerWrapper.h"
#include "spdlog/spdlog.h"
#include "spdlog/sinks/stdout_color_sinks.h"

GRPAppBegin

LoggerWrapper* LoggerWrapper::Instance()
{
	if (NULL == m_instance.get())
	{
		m_instance = std::make_unique<LoggerWrapper>();
	}
	return m_instance.get();
}

std::unique_ptr<GRPApp::LoggerWrapper> GRPApp::LoggerWrapper::m_instance;

void GRPApp::LoggerWrapper::Init()
{
#ifdef __Debug
	spdlog::set_level(spdlog::level::debug);
#else
#endif
	//注册不同的log方式
	auto console = spdlog::stdout_color_mt("console");
	auto out_error = spdlog::stderr_color_mt("stderr");

}

GRPApp::LoggerWrapper::LoggerWrapper()
{
	Init();
}

GRPAppEnd
