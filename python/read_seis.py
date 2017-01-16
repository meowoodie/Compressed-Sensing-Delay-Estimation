import array
from ctypes import *

CSIZE  = 1800000
FTSIZE = 1048576

class SEIS_HEADER(Structure):
    """
    struct seis_header
    {
        int	nt;
        int	id;
        int	rline;	/* receiver line # */
        int	rpt;	/* index on receiver line */
        char	name[8];
        double	x, y, z;
        double	t0;
        double	dt;
    };
    """
    
    _fields_ = [('nt', c_int),
                ('id', c_int),
                ('rline', c_int),
                ('rpt', c_int),
                ('name', c_char * 8),
                ('x', c_double),
                ('y', c_double),
                ('z', c_double),
                ('t0', c_double),
                ('dt', c_double)]

class SEIS_DATA(Structure):
    _fields_ = [('data', c_float * CSIZE)]

def seis_reader(file_path):
    with open(file_path, 'rb') as file:
        # Init the data structures
        header_struct = SEIS_HEADER()
        data_struct   = SEIS_DATA()
        # Read the seis header
        file.readinto(header_struct)
        header = [header_struct.nt, header_struct.id, \
                  header_struct.rline, header_struct.rpt, header_struct.name, \
                  header_struct.x, header_struct.y, header_struct.z, \
                  header_struct.t0, header_struct.dt]

        # Read the seis data
        if header_struct.nt < CSIZE:
            # break
            exit(0)
        file.readinto(data_struct)
        data = data_struct.data

    # Another way for extracting seis data
    # data = array.array('f', file.read())

    return header, data

if __name__ == '__main__':
    import sys
    # Exp. '/Users/woodie/Desktop/Georgia-Tech-ISyE-Intern/xcorr_hongao/data/4001-0000/20140801000000.4001-0000.seis'
    file_path = sys.argv[1]
    header, data = seis_reader(file_path)
    # print '\t'.join(map(str, header))
    print '\n'.join(map(str, data))

   
