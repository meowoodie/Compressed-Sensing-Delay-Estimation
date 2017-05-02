import os
import sys
import arrow
import numpy as np
import subprocess

root_path   = '../../utah'
output_path = '../../stacked_utah_dataset'
date_ranges = [
	'09162016',
	'09172016',
	'09182016',
	'09192016',
	'09202016',
	'09212016',
	'09222016'
]

# Traverse station folders
for station in os.listdir(root_path):
	if station[0] == '.':
		continue
	# Output path
	stacked_path = '%s/%s' % (output_path, station)
	if not os.path.exists(stacked_path):
		os.makedirs(stacked_path)

	one_day_sum = []
	days_num    = float(len(os.listdir('%s/%s' % (root_path, station))))
	valid_data  = [ '%s.EHZ.%s.txt' % (station, date) for date in date_ranges ]
	# Traverse data files
	for data in os.listdir('%s/%s' % (root_path, station)):
		if data[0] == '.':
			continue
		if len(valid_data) > 0 and data not in valid_data:
			continue
		# Data path
		data_path = '%s/%s/%s' % (root_path, station, data)

		# Cat data file into stdout
		# proc = subprocess.Popen(['cat', data_path], stdout=subprocess.PIPE)
		# for line in proc.stdout.readlines():

		# Read data file by open cmd
		with open(data_path, 'r') as f:
			rawdata = f.readlines()
			if one_day_sum == []:
				one_day_sum = np.zeros(len(rawdata))

			print >> sys.stderr, '[%s] %s' % (arrow.now(), data)
			one_day_data = []
			for line in rawdata:
				one_day_data.append(float(line.strip().split()[1]))
			one_day_sum = np.array(one_day_data) + one_day_sum

	# -----------------------------------------------------------------
	# First step:
	# Stack data of all days into only one day
	# -----------------------------------------------------------------
	one_day_avg = one_day_sum/days_num
	with open('%s/stacked_one_day.txt' % stacked_path, 'w') as f:
		for value in one_day_avg.tolist():
			f.write('%f\n' % value)

	# -----------------------------------------------------------------
	# Second step:
	# Stack data of one day into 5 mins window
	# - Cut one day data into pieces with 5 mins length
	# - Stack those slices of data with 5min length into one
	# -----------------------------------------------------------------
	

