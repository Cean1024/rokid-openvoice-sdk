#include <chrono>
#include <grpc++/client_context.h>
#include "speech_connection.h"
#include "log.h"
#include "tts_req_handler.h"
#include "tts_impl.h"

using std::shared_ptr;
using grpc::ClientContext;
using rokid::open::TtsRequest;
using rokid::open::TtsHeader;

namespace rokid {
namespace speech {

const uint32_t grpc_timeout_ = 5;

TtsReqHandler::TtsReqHandler() : cancel_handler_(NULL) {
}

bool TtsReqHandler::prepare(SpeechConfig* config) {
	stub_ = SpeechConnection::connect(config, "tts");
	if (stub_.get() == NULL) {
		Log::d(tag__, "SpeechConnection for tts failed");
		return false;
	}
	return true;
}

shared_ptr<TtsRespStream> TtsReqHandler::poll() {
	shared_ptr<TtsRespStream> tmp = stream_;
	stream_.reset();
	return tmp;
}

static void config_client_context(ClientContext* ctx) {
	std::chrono::system_clock::time_point deadline =
		std::chrono::system_clock::now() + std::chrono::seconds(grpc_timeout_);
	ctx->set_deadline(deadline);
}

void TtsReqHandler::start_handle(shared_ptr<TtsReqInfo> in, void* arg) {
	if (in.get() && !in->deleted) {
		CommonArgument* carg = (CommonArgument*)arg;
		carg->current_id = in->id;
		carg->context = new ClientContext();
		config_client_context(carg->context);
	}
}

int32_t TtsReqHandler::handle(shared_ptr<TtsReqInfo> in, void* arg) {
	if (!in.get())
		return FLAG_ERROR;
	CommonArgument* carg = (CommonArgument*)arg;
	if (in->deleted) {
		cancel_handler_->cancelled(in->id);
		return FLAG_BREAK_LOOP;
	}

	TtsRequest req;
	TtsHeader* header = req.mutable_header();
	header->set_id(in->id);
	const char* v = carg->config.get("codec", "pcm");
	header->set_codec(v);
	v = carg->config.get("declaimer", "zh");
	header->set_declaimer(v);
	req.set_text(*in->data);
	stream_ = stub_->tts(carg->context, req);
	return 0;
}

void TtsReqHandler::end_handle(shared_ptr<TtsReqInfo> in, void* arg) {
	// do nothing
}

void TtsReqHandler::close() {
	stub_.reset();
}

bool TtsReqHandler::closed() {
	return false;
}

} // namespace speech
} // namespace rokid
