# Color Space Converter
# (c) 2018 by Christian Klukas
import warnings
import argparse
import io
import numpy
import cv2
from MemoryStream import *
from signal import signal, SIGPIPE, SIG_DFL
with warnings.catch_warnings():
	warnings.simplefilter('ignore', UserWarning) # ignore warning about not optimal speed
	import tifffile as tiff

parser = argparse.ArgumentParser(description='MCCCS V2 Colorspace Converter (c) 2018 C. Klukas. Read R/G/B input tiff files (value range 0..1), convert to H/S/V and L/a/b, save result gray-scale images.')

parser.add_argument('--version', action='version',
			version='MCCCS V2 Colorspace Converter (c) 2018 C. Klukas')
parser.add_argument('--input', dest='input', nargs="+", 
					help='input images (e.g. red, green, blue channel images with value range 0 to 1)')
parser.add_argument('--mode',  dest='mode',  nargs="+",
					help='conversion mode(s), either rgb2hsv, rgb2xyz or rgb2lab')
parser.add_argument('--output', dest='output_filenames', nargs='+', 
			help='list of target file names (in most cases three output channels can be saved)')

args = parser.parse_args()

channel_data = []

img_w = -1
img_h = -1

for channel_image in args.input:
	try:
		image = tiff.imread(channel_image)
		img_h = image.shape[0]
		img_w = image.shape[1]
	except OSError:
		# e.g. if seek is not possible (stdin), then read to mem and parse tif from mem
		with open(channel_image, 'rb') as input:
			image = tiff.imread(MemoryStream(input.read()))
			img_h = image.shape[0]
			img_w = image.shape[1]
			
	channel_data.append(image)

converted_channel_data = []

for mode in args.mode:
	# merge B / G / R
	img = cv2.merge((channel_data[2], channel_data[1], channel_data[0]))
	if mode=="rgb2hsv":
		img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
		img_h, img_s, img_v = cv2.split(img_hsv)
		converted_channel_data.append(img_h)
		converted_channel_data.append(img_s)
		converted_channel_data.append(img_v)
	if mode=="rgb2xyz":
		img_xyz = cv2.cvtColor(img, cv2.COLOR_BGR2XYZ)
		img_x, img_y, img_z = cv2.split(img_xyz)
		converted_channel_data.append(img_x)
		converted_channel_data.append(img_y)
		converted_channel_data.append(img_z)
	if mode=="rgb2lab":
		img_lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
		img_l, img_a, img_b = cv2.split(img_lab)
		converted_channel_data.append(img_l)
		converted_channel_data.append(img_a)
		converted_channel_data.append(img_b)

name_idx = 0
for channel in converted_channel_data:
	output_filename = args.output_filenames[name_idx]
	with open(output_filename, "wb") as out:
		if out.seekable():
			with tiff.TiffWriter(out, bigtiff=True) as tif_io:
				tif_io.save(channel)
		else:
			signal(SIGPIPE, SIG_DFL)
			mem_io = BytesIO()
			with tiff.TiffWriter(mem_io, bigtiff=True) as tif_io:
				tif_io.save(channel)
			mem_io.seek(0)
			tif_content_bytes = mem_io.read()
			out.write(tif_content_bytes)

	name_idx = name_idx + 1
