IGNORED_WARNINGS := -Wno-sign-compare -Wno-unused-parameter -Wno-sign-promo -Wno-error=return-type -Wno-error=non-virtual-dtor
COMMON_CFLAGS := -std=c++11 $(IGNORED_WARNINGS) -DSPEECH_LOG_ANDROID -frtti -fexceptions

include $(CLEAR_VARS)

LOCAL_MODULE := libspeech_common
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_TAGS := optional
LOCAL_CPP_EXTENSION := .cc

SPEECH_PROTO_FILE := $(LOCAL_PATH)/proto/speech.proto

PROTOC_OUT_DIR := $(call local-intermediates-dir)/gen
RPROTOC := $(HOST_OUT_EXECUTABLES)/aprotoc

PROTOC_GEN_SRC := \
	$(PROTOC_OUT_DIR)/speech.pb.cc

COMMON_SRC := \
	src/common/speech_config.cc \
	src/common/speech_config.h \
	src/common/log.cc \
	src/common/log.h \
	src/common/speech_connection.cc \
	src/common/speech_connection.h

LOCAL_C_INCLUDES := \
	$(PROTOC_OUT_DIR) \
	external/protobuf/src \
	external/boringssl/include

$(PROTOC_GEN_SRC): PRIVATE_CUSTOM_TOOL := $(RPROTOC) -I$(LOCAL_PATH)/proto --cpp_out=$(PROTOC_OUT_DIR) $(SPEECH_PROTO_FILE)
$(PROTOC_GEN_SRC): $(SPEECH_PROTO_FILE)
	$(transform-generated-source)
LOCAL_GENERATED_SOURCES := $(PROTOC_GEN_SRC)

LOCAL_SRC_FILES := $(COMMON_SRC)

LOCAL_CFLAGS := $(COMMON_CFLAGS)
LOCAL_SHARED_LIBRARIES := liblog libpoco libcrypto
ifneq ($(SDK_VERSION_23), true)
LOCAL_STATIC_LIBRARIES := libprotobuf-cpp-2.3.0-full-gnustl-rtti
LOCAL_SDK_VERSION := 14
LOCAL_NDK_STL_VARIANT := gnustl_static
LOCAL_CPPFLAGS := -D__STDC_FORMAT_MACROS
else
#LOCAL_STATIC_LIBRARIES := libprotobuf-cpp-full-gnustl-rtti
LOCAL_SHARED_LIBRARIES += libprotobuf-rokid-cpp-full
LOCAL_CXX_STL := libc++
endif
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/src/common $(LOCAL_C_INCLUDES)

include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := libspeech_tts
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_TAGS := optional
LOCAL_CPP_EXTENSION := .cc

LOCAL_SRC_FILES := \
	src/tts/tts_impl.cc \
	src/tts/tts_impl.h \
	src/tts/types.h \
	src/common/pending_queue.h \
	src/common/op_ctl.h

LOCAL_C_INCLUDES := \
	$(PROTOC_OUT_DIR) \
	$(LOCAL_PATH)/include

LOCAL_CFLAGS := $(COMMON_CFLAGS)
LOCAL_SHARED_LIBRARIES := libspeech_common libpoco
ifneq ($(SDK_VERSION_23), true)
LOCAL_CPPFLAGS := -DLOW_PB_VERSION
LOCAL_SDK_VERSION := 14
LOCAL_NDK_STL_VARIANT := gnustl_static
else
LOCAL_CXX_STL := libc++
LOCAL_SHARED_LIBRARIES += libprotobuf-rokid-cpp-full
endif

include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := libspeech_asr
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_TAGS := optional
LOCAL_CPP_EXTENSION := .cc

LOCAL_SRC_FILES := \
	src/asr/asr_impl.cc \
	src/asr/asr_impl.h \
	src/asr/types.h \
	src/common/pending_queue.h \
	src/common/op_ctl.h

LOCAL_C_INCLUDES := \
	$(PROTOC_OUT_DIR) \
	$(LOCAL_PATH)/include

LOCAL_CFLAGS := $(COMMON_CFLAGS)
LOCAL_SHARED_LIBRARIES := libspeech_common libpoco
ifneq ($(SDK_VERSION_23), true)
LOCAL_SDK_VERSION := 14
LOCAL_NDK_STL_VARIANT := gnustl_static
LOCAL_CPPFLAGS := -DLOW_PB_VERSION
else
LOCAL_CXX_STL := libc++
LOCAL_SHARED_LIBRARIES += libprotobuf-rokid-cpp-full
endif

include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := libspeech
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_TAGS := optional
LOCAL_CPP_EXTENSION := .cc

LOCAL_SRC_FILES := \
	src/speech/speech_impl.cc \
	src/speech/speech_impl.h \
	src/speech/types.h \
	src/common/pending_queue.h \
	src/common/op_ctl.h

LOCAL_C_INCLUDES := \
	$(PROTOC_OUT_DIR) \
	$(LOCAL_PATH)/include

LOCAL_CFLAGS := $(COMMON_CFLAGS)
LOCAL_SHARED_LIBRARIES := libspeech_common libpoco
ifneq ($(SDK_VERSION_23), true)
LOCAL_SDK_VERSION := 14
LOCAL_NDK_STL_VARIANT := gnustl_static
else
LOCAL_CXX_STL := libc++
LOCAL_SHARED_LIBRARIES += libprotobuf-rokid-cpp-full
endif
include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := speech_demo
LOCAL_MODULE_TAGS := optional
LOCAL_CPP_EXTENSION := .cc
LOCAL_SRC_FILES := \
	demo/demo.cc \
	demo/tts_demo.cc \
	demo/asr_demo.cc \
	demo/speech_demo.cc
LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/include \
	$(LOCAL_PATH)/src/common \
	$(PROTOC_OUT_DIR) \
	external/protobuf/src \
	external/boringssl/include
LOCAL_SHARED_LIBRARIES := libpoco libspeech_common libspeech_tts libspeech_asr libspeech
LOCAL_CPPFLAGS := $(COMMON_CFLAGS)
ifneq ($(SDK_VERSION_23), true)
LOCAL_SDK_VERSION := 14
LOCAL_NDK_STL_VARIANT := gnustl_static
else
LOCAL_CXX_STL := libc++
#LOCAL_SHARED_LIBRARIES += libprotobuf-rokid-cpp-full
endif

include $(BUILD_EXECUTABLE)
