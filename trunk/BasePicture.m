//
//  BasePicture.m
//  Finger
//
//  Created by Ivan Dilchovski on 10/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BasePicture.h"
#define PNG_HEADER_SIZE 8


@implementation BasePicture
@synthesize pixelSize;
@synthesize oglSize;
@synthesize texName;
@synthesize filePath;

- (id) initWithPath:(NSString*) filePath
{
	if(self = [super init])
	{
		self.filePath = filePath;
		
		unsigned char *imageData = [self loadPng];
		if(!imageData)
		{
			return nil;
		}
		
		glGenTextures(1, &texName);
		glBindTexture(GL_TEXTURE_2D, texName);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
		
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, pixelSize.width, pixelSize.height, 0, 
					 GL_RGBA, GL_UNSIGNED_BYTE, imageData);
		free(imageData);
		
		oglSize.width = BASE_PICTURE_SIZE;
		oglSize.height = oglSize.width * (pixelSize.height / pixelSize.width);
	}
	
	return self;
}

- (unsigned char*) loadPng
{
	const char *path = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
	FILE *PNG_file = fopen(path, "rb");
	if (PNG_file == NULL)
	{
		[Logger logMessage:[NSString stringWithFormat:@"Can't open PNG file %s\n", path] ofType:DEBUG_ERROR];
		return;
	}
	
	GLubyte PNG_header[PNG_HEADER_SIZE];
	
	fread(PNG_header, 1, PNG_HEADER_SIZE, PNG_file);
	if (png_sig_cmp(PNG_header, 0, PNG_HEADER_SIZE) != 0)
	{
		[Logger logMessage:[NSString stringWithFormat:@"%s is not a PNG file\n", path] ofType:DEBUG_ERROR];
		return;
	}
	
	png_structp PNG_reader
	= png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	if (PNG_reader == NULL)
	{
		[Logger logMessage:[NSString stringWithFormat:@"Can't start reading PNG file %s\n", path] ofType:DEBUG_ERROR];
		fclose(PNG_file);
		
		return;
	}
	
	png_infop PNG_info = png_create_info_struct(PNG_reader);
	if (PNG_info == NULL)
	{
		[Logger logMessage:[NSString stringWithFormat:@"Can't get info for PNG file %s\n", path] ofType:DEBUG_ERROR];
		png_destroy_read_struct(&PNG_reader, NULL, NULL);
		fclose(PNG_file);
		
		return;
	}
	
	png_infop PNG_end_info = png_create_info_struct(PNG_reader);
	if (PNG_end_info == NULL)
	{
		[Logger logMessage:[NSString stringWithFormat:@"Can't get end info for PNG file %s\n", path] ofType:DEBUG_ERROR];
		png_destroy_read_struct(&PNG_reader, &PNG_info, NULL);
		fclose(PNG_file);
		
		return;
	}
	
	if (setjmp(png_jmpbuf(PNG_reader)))
	{
		[Logger logMessage:[NSString stringWithFormat:@"Can't load PNG file %s\n", path] ofType:DEBUG_ERROR];
		png_destroy_read_struct(&PNG_reader, &PNG_info, &PNG_end_info);
		fclose(PNG_file);
		
		return;
	}
	
	png_init_io(PNG_reader, PNG_file);
	png_set_sig_bytes(PNG_reader, PNG_HEADER_SIZE);
	
	png_read_info(PNG_reader, PNG_info);
	
	png_uint_32 width, height;
	width = png_get_image_width(PNG_reader, PNG_info);
	height = png_get_image_height(PNG_reader, PNG_info);
	
	png_uint_32 bit_depth, color_type;
	bit_depth = png_get_bit_depth(PNG_reader, PNG_info);
	color_type = png_get_color_type(PNG_reader, PNG_info);
	
	if (color_type == PNG_COLOR_TYPE_PALETTE)
	{
		png_set_palette_to_rgb(PNG_reader);
	}
	if (color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8) 
	{
		png_set_gray_1_2_4_to_8(PNG_reader);
	}
	if (color_type == PNG_COLOR_TYPE_GRAY || color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
	{
		png_set_gray_to_rgb(PNG_reader);
	}
	if (png_get_valid(PNG_reader, PNG_info, PNG_INFO_tRNS))
	{
		png_set_tRNS_to_alpha(PNG_reader);
	}
	else
	{
		png_set_filler(PNG_reader, 0xff, PNG_FILLER_AFTER);
	}
	if (bit_depth == 16)
	{
		png_set_strip_16(PNG_reader);
	}
	
	png_read_update_info(PNG_reader, PNG_info);
	
	png_byte* PNG_image_buffer = (png_byte*)malloc(4 * width * height);
	png_byte** PNG_rows = (png_byte**)malloc(height * sizeof(png_byte*));
	
	unsigned int row;
	for (row = 0; row < height; ++row)
	{
		PNG_rows[height - 1 - row] = PNG_image_buffer + (row * 4 * width);
	}
	
	png_read_image(PNG_reader, PNG_rows);
	
	free(PNG_rows);
	
	png_destroy_read_struct(&PNG_reader, &PNG_info, &PNG_end_info);
	fclose(PNG_file);

	pixelSize.width = width;
	pixelSize.height = height;
	
	return PNG_image_buffer;
}

@end
