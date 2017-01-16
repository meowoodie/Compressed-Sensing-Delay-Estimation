import sys
import glob
import json
from collections import defaultdict

# Utils 
def nested_set(dic, keys, value):
    for key in keys[:-1]:
        dic = dic.setdefault(key, {})
    dic[keys[-1]] = value

# Seismic data (txt) reader
def txt_reader(file_path):
    with open(file_path, 'rb') as file:
        data = []
        for line in file:
            data.append(float(line.strip()))
    return data

# Get the mean of a day
def get_one_day_mean(one_day_dict):
    
    # Init the sum of the data
    sum_data = []
    for i in range(0, 1800000):
        sum_data.append(0)
    
    # Add data of each hour
    count = 0
    for hour, data_path in one_day_dict.iteritems():
        one_hour_data = txt_reader(data_path)
        if len(one_hour_data) != 1800000:
            print >> sys.stderr, 'The length of the data of hour %s is incorrect.' % hour
            continue
        sum_data = map(lambda x: x[0]+float(x[1]), zip(sum_data, one_hour_data))
        count += 1
    if count < 20:
        print >> sys.stderr, 'The data of this day is insufficient. Only %s hours are available' % count
    return map(lambda x: x/count, sum_data)

if __name__ == '__main__':
    input_station_path  = sys.argv[1]
    output_station_path = sys.argv[2]
    full_file_name_list  = glob.glob(input_station_path+'/*.txt')
    timestamp_list      = map(lambda x: [x.split('/')[-1].split('.')[0], x], full_file_name_list)
    formatted_dict_list = map(lambda x: {'year': x[0][0:4], 'mon': x[0][4:6], 'day': x[0][6:8], 'hour': x[0][8:10], 'path': x[1]}, timestamp_list)
    
    data_info_dict = {}
    for i in formatted_dict_list: 
        nested_set(data_info_dict, [i['year'], i['mon'], i['day'], i['hour']], i['path'])
        
    with open(output_station_path+'/data_info.txt', 'w') as file:
        file.write(json.dumps(data_info_dict, indent=2))

    for year, y_value in data_info_dict.iteritems():
        for mon, m_value in y_value.iteritems():
            for day, d_value in m_value.iteritems():
                print 'Generating the mean data of Year %s Mon %s Day %s...' % (year, mon, day)
                one_day_mean_data = get_one_day_mean(d_value)
                with open(output_station_path+'/%s%s%s.avg.txt' % (year, mon, day), 'w') as file:
                    for data_point in one_day_mean_data:
                        file.write(str(data_point)+'\n')
