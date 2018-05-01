# Extract channel images from source tiff file
# (c) 2018 by Christian Klukas
import warnings
import argparse
import io
import numpy
from MemoryStream import *
from signal import signal, SIGPIPE, SIG_DFL
with warnings.catch_warnings():
	warnings.simplefilter('ignore', UserWarning) # ignore warning about not optimal speed
	import tifffile as tiff

parser = argparse.ArgumentParser(description='MCCCS V2 Channel Extractor (c) 2018 C. Klukas. Read input tiff file, extract specified or all channel(s) and save result gray-scale image(s).')

parser.add_argument('--version', action='version',
		    version='MCCCS V2 Channel Extractor (c) 2018 C. Klukas')
parser.add_argument('--image', dest='image', default='/dev/stdin',
		    help='input file, default stdin')
parser.add_argument('--channels', dest='channels',  type=int, nargs='+',
		    help='channels to be extracted')
parser.add_argument('--all', dest='all', default=False, action='store_true',
		    help='if flag is provided, extract all channels')
parser.add_argument('--8bitToFloat32', dest='div256_32', default=False, action='store_true',
		    help='if flag is provided, input data is divided by 256, floating point output (32 bit)')
parser.add_argument('--8bitToFloat64', dest='div256_64', default=False, action='store_true',
		    help='if flag is provided, input data is divided by 256, floating point output (64 bit)')
parser.add_argument('--target',  dest='target', default='/dev/stdout',
		    help='target file, default stdout, character # is replaced by channel number, use multiple # to pad the number')
parser.add_argument('--targets', dest='targets', nargs='+', 
		    help='list of target file names if more than one channel is extracted')

args = parser.parse_args()

try:
	image = tiff.imread(args.image)
except OSError:
	# e.g. if seek is not possible (stdin), then read to mem and parse tif from mem
	with open(args.image, 'rb') as input:
		image = tiff.imread(MemoryStream(input.read()))

if not args.all:
	channel_list = args.channels
else:
	channel_list = range(image.shape[2])

name_idx = 0
for channel_idx in channel_list:
	channel = image[:, :, channel_idx]

	if args.div256_32 and not args.div256_64:
		channel = channel / numpy.float32(256.)
	else:
		if args.div256_64:
			channel = channel / 256.

	if args.targets == None:	
		target_filename = args.target
	else:
		target_filename = args.targets[name_idx % len(args.targets)]

	target_filename = target_filename.replace('####', '{0:04d}'.format(channel_idx))
	target_filename = target_filename.replace('###',  '{0:03d}'.format(channel_idx))
	target_filename = target_filename.replace('##',   '{0:02d}'.format(channel_idx))
	target_filename = target_filename.replace('#',    '{0:01d}'.format(channel_idx))

	with open(target_filename, "wb") as out:
		if out.seekable():
			with tiff.TiffWriter(target_filename, bigtiff=True) as tif_io:
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
