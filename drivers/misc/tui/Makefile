#
# Makefile for the stui Module
#

obj-$(CONFIG_SAMSUNG_TUI)	+= main.o
obj-$(CONFIG_SAMSUNG_TUI)	+= stui_core.o
obj-$(CONFIG_SAMSUNG_TUI)	+= stui_inf.o

ifeq ($(CONFIG_SOC_EXYNOS7885),y)
ifneq ($(CONFIG_TEEGRIS_VERSION),2)
ccflags-$(CONFIG_SAMSUNG_TUI)	+= -DUSE_TEE_CLIENT_API
ccflags-$(CONFIG_SAMSUNG_TUI)	+= -Idrivers/misc/tzdev/$(CONFIG_TEEGRIS_VERSION).0/include/tzdev
endif
obj-$(CONFIG_SAMSUNG_TUI)	+= platforms/exynos7885/
endif

ifeq ($(CONFIG_SOC_EXYNOS9610),y)
ccflags-$(CONFIG_SAMSUNG_TUI)	+= -DUSE_TEE_CLIENT_API
ccflags-$(CONFIG_SAMSUNG_TUI)	+= -Idrivers/misc/tzdev/include/tzdev
obj-$(CONFIG_SAMSUNG_TUI)	+= platforms/exynos9610/
ccflags-$(CONFIG_SAMSUNG_TUI)	+= -Idrivers/video/fbdev/exynos/dpu20
endif

ccflags-$(CONFIG_SAMSUNG_TUI_TEST)	+= -DSAMSUNG_TUI_TEST
obj-$(CONFIG_SAMSUNG_TUI_TEST)	+= test_driver/
