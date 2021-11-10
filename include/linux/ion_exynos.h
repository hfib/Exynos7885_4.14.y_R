/*
 * include/linux/ion_exynos.h
 *
 * Copyright (C) 2018 Samsung Electronics Co., Ltd.
 *
 * This software is licensed under the terms of the GNU General Public
 * License version 2, as published by the Free Software Foundation, and
 * may be copied, distributed, and modified under those terms.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#ifndef __LINUX_ION_EXYNOS_H__
#define __LINUX_ION_EXYNOS_H__

#include <linux/dma-direction.h>

struct dma_buf_attachment;

#define ION_FLAG_CACHED 1
#define ION_FLAG_NOZEROED 8
#define ION_FLAG_PROTECTED 16

#define EXYNOS_ION_HEAP_SYSTEM_ID 0
#define EXYNOS_ION_HEAP_EXYNOS_CONTIG_ID 4
#define EXYNOS_ION_HEAP_CARVEOUT_ID EXYNOS_ION_HEAP_EXYNOS_CONTIG_ID

#define EXYNOS_ION_HEAP_SYSTEM_MASK		(1 << EXYNOS_ION_HEAP_SYSTEM_ID)
#define EXYNOS_ION_HEAP_EXYNOS_CONTIG_MASK	(1 << EXYNOS_ION_HEAP_EXYNOS_CONTIG_ID)
#define EXYNOS_ION_HEAP_CARVEOUT_MASK		(1 << EXYNOS_ION_HEAP_CARVEOUT_ID)
#define EXYNOS_ION_HEAP_CRYPTO_MASK		(1 << ION_EXYNOS_HEAP_ID_CRYPTO)
#define EXYNOS_ION_HEAP_VIDEO_FW_MASK		(1 << ION_EXYNOS_HEAP_ID_VIDEO_FW)
#define EXYNOS_ION_HEAP_VIDEO_STREAM_MASK	(1 << ION_EXYNOS_HEAP_ID_VIDEO_STREAM)
#define EXYNOS_ION_HEAP_VIDEO_FRAME_MASK	(1 << ION_EXYNOS_HEAP_ID_VIDEO_FRAME)
#define EXYNOS_ION_HEAP_VIDEO_SCALER_MASK	(1 << ION_EXYNOS_HEAP_ID_VIDEO_SCALER)
#define EXYNOS_ION_HEAP_SECURE_CAMERA		(1 << ION_EXYNOS_HEAP_ID_SECURE_CAMERA)

enum {
	ION_EXYNOS_ID_COMMON		= 0,
	ION_EXYNOS_ID_VIDEO_EXT		= 1,
	ION_EXYNOS_ID_MFC_SH		= 2,
	ION_EXYNOS_ID_MSGBOX_SH		= 3,
	ION_EXYNOS_ID_FIMD_VIDEO	= 4,
	ION_EXYNOS_ID_GSC		= 5,
	ION_EXYNOS_ID_MFC_OUTPUT	= 6,
	ION_EXYNOS_ID_MFC_INPUT		= 7,
	ION_EXYNOS_ID_MFC_FW		= 8,
	ION_EXYNOS_ID_SECTBL		= 9,
	ION_EXYNOS_ID_G2D_WFD		= 10,
	ION_EXYNOS_ID_VIDEO             = 11,
	ION_EXYNOS_ID_MFC_NFW           = 12,
	ION_EXYNOS_ID_SECDMA		= 13,
	EXYNOS_ION_CONTIG_ID_NUM,
};

enum {
	ION_EXYNOS_HEAP_ID_CRYPTO		= 1,
	ION_EXYNOS_HEAP_ID_VIDEO_FW		= 2,
	ION_EXYNOS_HEAP_ID_VIDEO_STREAM		= 3,
	ION_EXYNOS_HEAP_ID_RESERVED		= 4,
	ION_EXYNOS_HEAP_ID_VIDEO_FRAME		= 5,
	ION_EXYNOS_HEAP_ID_VIDEO_SCALER		= 6,
	ION_EXYNOS_HEAP_ID_VIDEO_NFW		= 7,
	ION_EXYNOS_HEAP_ID_SECURE_CAMERA	= 11,
#ifdef CONFIG_HPA_EXTRA
	ION_EXYNOS_HEAP_ID_EXTRA_VFRAME		= 16,
#endif
};

#ifdef CONFIG_ION_EXYNOS
struct dma_buf *ion_alloc_dmabuf(const char *heap_name,
				 size_t len, unsigned int flags);
bool ion_cached_dmabuf(struct dma_buf *dmabuf);
bool ion_hwrender_dmabuf(struct dma_buf *dmabuf);
#else
static inline struct dma_buf *ion_alloc_dmabuf(const char *heap_name,
					       size_t len, unsigned int flags)
{
	return ERR_PTR(-ENODEV);
}

static inline bool ion_cached_dmabuf(struct dma_buf *dmabuf)
{
	return false;
}

static inline bool ion_cached_hwrender(struct dma_buf *dmabuf)
{
	return false;
}
#endif

#if defined(CONFIG_EXYNOS_IOVMM) && defined(CONFIG_ION_EXYNOS)
#define IOMMU_EXYNOS_SECURE	(1 << 0)

dma_addr_t ion_iovmm_map(struct dma_buf_attachment *attachment,
			 off_t offset, size_t size,
			 enum dma_data_direction direction, int prop);
void ion_iovmm_unmap(struct dma_buf_attachment *attachment, dma_addr_t iova);
dma_addr_t ion_iovmm_map_attr(struct dma_buf_attachment *attachment,
			      off_t offset, size_t size,
			      enum dma_data_direction direction, int prop,
			      int map_attr);
void ion_iovmm_unmap_attr(struct dma_buf_attachment *attachment,
			  dma_addr_t iova, int map_attr);
#else
static inline dma_addr_t ion_iovmm_map(struct dma_buf_attachment *attachment,
				       off_t offset, size_t size,
				       enum dma_data_direction direction,
				       int prop)
{
	return -ENODEV;
}
#define ion_iovmm_unmap(attachment, iova) do { } while (0)
static inline dma_addr_t ion_iovmm_map_attr(struct dma_buf_attachment *attachment,
					    off_t offset, size_t size,
					    enum dma_data_direction direction,
					    int prop, int map_attr)
{
	return -ENODEV;
}
#define ion_iovmm_unmap(attachment, iova, map_attr) do { } while (0)

#endif

#endif /* __LINUX_ION_EXYNOS_H__ */
