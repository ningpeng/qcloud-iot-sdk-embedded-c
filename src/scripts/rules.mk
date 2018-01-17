iot_sdk_objects = $(patsubst %.c,%.o, $(IOTSDK_SRC_FILES))
iot_platform_objects = $(patsubst %.c,%.o, $(IOTPLATFORM_SRC_FILES))

.PHONY: config mbedtls clean final-out final tests

all: config mbedtls ${COMP_LIB} ${PLATFORM_LIB} final-out final tests cleans

${COMP_LIB}: ${iot_sdk_objects}
	$(TOP_Q) \
	$(AR) rcs $@ $(iot_sdk_objects)
	
	$(TOP_Q) \
	rm ${iot_sdk_objects}
	
${PLATFORM_LIB}: ${iot_platform_objects}
	$(TOP_Q) \
	$(AR) rcs $@ $(iot_platform_objects)
	
	$(TOP_Q) \
	rm ${iot_platform_objects}
	
config:
	$(TOP_Q) \
	mkdir -p ${TEMP_DIR}
	
mbedtls:
	$(TOP_Q) \
	make -s -C $(THIRD_PARTY_PATH)/mbedtls lib -e CC=$(PLATFORM_CC) AR=$(PLATFORM_AR)
	
	$(TOP_Q) \
	cp -RP  $(THIRD_PARTY_PATH)/mbedtls/library/libmbedtls.*  \
			$(THIRD_PARTY_PATH)/mbedtls/library/libmbedx509.* \
			$(THIRD_PARTY_PATH)/mbedtls/library/libmbedcrypto.* \
			$(TEMP_DIR)
	
	$(TOP_Q) \
	cd $(TEMP_DIR) && $(AR) x libmbedtls.a \
						&& $(AR) x libmbedx509.a \
						&& $(AR) x libmbedcrypto.a

${iot_sdk_objects}:%.o:%.c
	$(TOP_Q) \
	$(PLATFORM_CC) $(CFLAGS) -c $^ -o $@
	
${iot_platform_objects}:%.o:%.c
	$(TOP_Q) \
	$(PLATFORM_CC) $(CFLAGS) -c $^ -o $@
	
include $(TOP_DIR)/src/scripts/rules-final.mk
include $(TOP_DIR)/src/scripts/rules-tests.mk

clean: cleans
	$(TOP_Q) \
	rm -rf ${TEMP_DIR}
	
	$(TOP_Q) \
	rm -rf ${DIST_DIR}
	
	$(TOP_Q) \
	make -s -C $(THIRD_PARTY_PATH)/mbedtls clean