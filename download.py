# -*- coding: UTF-8 -*-
from ftplib import FTP, error_perm
from callback_config import get_pc_type
import os


bufsize = 1024
exclusive_packages = {'bts': ['jre-6u37-windows-i586.exe', 'update_java_env.bat', 'robotframework-2.8.4.win32.exe',
                              'robotframework-ride-1.3.win32.exe', 'robotframework-master_2.9.1.zip',
                              'wxPython3.0-win32-3.0.2.0-py27.exe'],
                      'tm500': ['robotframework-2.8.4.win32.exe'],
                      'rnc': [],
                      'dct': []
                      }
common_packages = ['setx.exe', 'setup.exe', 'update_python_env.bat', 'python-2.7.10.msi', 'callback_config.exe',
                   'TortoiseSVN-1.7.11.23600-win32-svn-1.7.8.msi', 'TortoiseSVN-1.8.8.25755-x64-svn-1.8.10.msi']

def Get(filename):
    command = 'RETR ' + filename
    try:
        ftp.retrbinary(command, open(filename, 'wb').write, bufsize)
    except error_perm:
        print "download %s with error %s!" % (filename, error_perm)
        return False
    print "download %s successfully!" % filename
    return True


def dowmload_file():
    ftp.cwd('/TA/AutoInstall/SW')
    to_be_download = exclusive_packages[get_pc_type()] + common_packages
    for f in to_be_download:
        if not Get(f):
            ftp.quit()
            raise Exception('download failed!')


ftp = FTP()
timeout = 30
port = 21
ftp.connect('10.69.195.222', port, timeout)
ftp.login('microrec', 'microrec')
dowmload_file()
os.system("setup.exe")
