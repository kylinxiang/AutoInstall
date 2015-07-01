import time
import sys
import traceback
import types
import zipfile

from main.get_mmt_port import *
from main.cmd_exec import *

Host = get_rdp_ip()


def isUserAdmin():
    if os.name == 'nt':
        import ctypes
        # WARNING: requires Windows XP SP2 or higher!
        try:
            return ctypes.windll.shell32.IsUserAnAdmin()
        except:
            traceback.print_exc()
            print "Admin check failed, assuming not an admin."
            return False
    elif os.name == 'posix':
        # Check for root on Posix
        return os.getuid() == 0
    else:
        raise RuntimeError, "Unsupported operating system for this module: %s" % (os.name,)


def runAsAdmin(cmdLine=None, wait=True):
    if os.name != 'nt':
        raise RuntimeError, "This function is only implemented on Windows."

    import win32con, win32event, win32process
    from win32com.shell.shell import ShellExecuteEx
    from win32com.shell import shellcon

    python_exe = sys.executable

    if cmdLine is None:
        cmdLine = [python_exe] + sys.argv
    elif type(cmdLine) not in (types.TupleType, types.ListType):
        raise ValueError, "cmdLine is not a sequence."
    cmd = '"%s"' % (cmdLine[0],)
    # XXX TODO: isn't there a function or something we can call to massage command line params?
    params = " ".join(['"%s"' % (x,) for x in cmdLine[1:]])
    cmdDir = ''
    showCmd = win32con.SW_SHOWNORMAL
    # showCmd = win32con.SW_HIDE
    lpVerb = 'runas'  # causes UAC elevation prompt.

    # print "Running", cmd, params

    # ShellExecute() doesn't seem to allow us to fetch the PID or handle
    # of the process, so we can't get anything useful from it. Therefore
    # the more complex ShellExecuteEx() must be used.

    # procHandle = win32api.ShellExecute(0, lpVerb, cmd, params, cmdDir, showCmd)

    procInfo = ShellExecuteEx(nShow=showCmd,
                              fMask=shellcon.SEE_MASK_NOCLOSEPROCESS,
                              lpVerb=lpVerb,
                              lpFile=cmd,
                              lpParameters=params)

    if wait:
        procHandle = procInfo['hProcess']
        obj = win32event.WaitForSingleObject(procHandle, win32event.INFINITE)
        rc = win32process.GetExitCodeProcess(procHandle)
        # print "Process handle %s returned code %s" % (procHandle, rc)
    else:
        rc = None

    return rc


def get_lab_interface_gateway():
    get_intf_ip = 'tracert -d -h 1 %s' % Host
    ip_info = execute_cmd(get_intf_ip)
    # print ip_info
    prog = re.compile('.*(10\.69(\.[0-9]+){2})', re.DOTALL)
    gateway = prog.match(ip_info).groups()[0]
    return gateway


def get_pc_type():
    pc_type = get_device_type().lower()
    if pc_type in ['a', 'b', 'c']:
        return 'tm500'
    elif pc_type in ['aritza', 'srac']:
        return 'rnc'
    return pc_type

get_newest_file = lambda x: os.path.getmtime(x)


def search_file(filename):
    root_folders = filter(lambda x: os.path.exists(x), ["C:\\", "D:\\", "E:\\", "F:\\"])
    found_files = map(lambda x: get_file_path(x, filename), root_folders)
    print found_files
    return max([item for sublist in found_files for item in sublist], key=get_newest_file).replace('\\', '/')


# DCT path
def get_file_path(floder_path, filename):
    file_list = []
    if floder_path is None:
        raise Exception("floder_path is None")
    for dirpath, dirnames, filenames in os.walk(floder_path):
        for name in filenames:
            if filename in name:
                file_list.append(dirpath)
    return file_list


# TM500 path
def find_TM_path():
    dirname = 'C:\Program Files\Aeroflex\TM500'
    candidate_dirs = get_dir_path(dirname, get_device_type().upper())
    return max(candidate_dirs, get_newest_file)


def get_dir_path(floder_path, type):
    file_list = []
    type_match = {'A': 'E\d', 'B': 'W\d', 'C': 'WSC\d'}
    for dir_name in os.listdir(floder_path):
        m = re.match(type_match[type], dir_name.split(' - ')[1])
        if m is not None:
            file_list.append(floder_path + '\\' + dir_name)
    return file_list


def send_variable(k, v):
    username = 'upl1-tester'
    password = 'btstest'
    tn = telnetlib.Telnet(Host)
    tn.read_until('Login username:')
    tn.write(username + '\r\n')
    tn.read_until('Login password:')
    tn.write(password + '\r\n')
    tn.read_until('Domain name:')
    tn.write('\r\n')
    tn.read_until('C:\\>')
    print "telnet success!"

    tn.write('d:\r\n')
    tn.read_until('D:\\>')
    tn.write('cd D:\LiZiqiang\\auto_install' + '\r\n')
    tn.read_until('D:\\LiZiqiang\\auto_install>')
    tn.write('python\r\n')
    tn.read_until('>>>')
    tn.write('from get_mmt_port import modify_para' + '\r\n')
    tn.read_until('>>>')
    tn.write('modify_para("%s", "%s")' % (k, v))
    tn.write('\r\n')
    tn.read_until('>>>')
    print "modify success"

    tn.write('exit()\r\n')
    tn.read_until('D:\\LiZiqiang\\auto_install>')
    # tn.close()
    tn.write('exit\r\n')
    print "exit"


def get_device_type():
    with open('C:/Users/upl1-tester/Device_Type.txt', 'r') as f:
        temp_type = f.read().strip()
        return temp_type


def patch_robot():
    zfile = zipfile.ZipFile('C:/Users/upl1-tester/robotframework-master_2.9.1.zip')
    zfile.extractall()
    subprocess.call("C: && cd C:/Users/upl1-tester/robotframework-master && C:/Python27/python.exe setup.py install", shell=True)


def config_bts():
    patch_robot()
    send_variable("CFG_MMT_Path", search_file('MMT.exe'))
    send_variable("CFG_DSPExplorer_Dir", search_file('DSPExplorer_GUI.exe'))
    send_variable("CFG_BTSLogTool_Path", search_file('BTSlog2.exe'))
    send_variable("CFG_MMT_CaptureInterface", str(get_mmt_port()))
    cmds = ['cd Users\upl1-tester', 'echo succeed > callback_succeed.txt']
    do_telnet(Host, cmds)
    # so that rdp.exe can move on to commit
    time.sleep(60)


def config_dct():
    send_variable("CFG_DCT_Path", search_file('EUL_DCT.exe'))


def config_tm500():
    tm500_path = find_TM_path()[0] + "/ftp_root/LOG"
    tm500_dir = tm500_path.replace('\\', '/')
    send_variable("CFG_TM500_LocalLog_Dir", tm500_dir)

def config_rnc():
    pass


def create_bts():
    cmd = "svn co --username ziqli --password Tp312ja05i http://svni1.access.nokiasiemensnetworks.com/isource/" \
          "svnroot/dcm_iv_ws/trunk/IVLRC3G_Robot_R1.0/ D:\\trunk\\IVLRC3G_Robot_R1.0"
    do_svn_checkout(cmd)
    cmd = "svn co --username ziqli --password Tp312ja05i http://svni1.access.nokiasiemensnetworks.com/isource/" \
          "svnroot/dcm_iv_ws/trunk/TA_TestCase D:\\trunk\\TA_TestCase"
    do_svn_checkout(cmd)

def create_dct():
    DCT_install_path = search_file('EUL_DCT.exe')
    log_path = DCT_install_path + "/Automation_Log"
    if not os.path.exists(log_path):
        os.makedirs(log_path)
    EUL_DCT_file = DCT_install_path + "/EUL_DCT.INI"
    print EUL_DCT_file
    with open(EUL_DCT_file, 'r') as f:
        s = f.read()
    old = re.findall('.*(MeasurementDataSavePath =.*)', s)[0]
    new = "MeasurementDataSavePath =" + log_path
    replaced_text = s.replace(old, new)
    with open(EUL_DCT_file, 'w+') as f:
        f.write(replaced_text)

    cmd = "svn co --username ziqli --password Tp312ja05i http://svni1.access.nokiasiemensnetworks.com/isource/svnroot/" \
          "dcm_iv_ws/trunk/IVLRC3G_Robot_R1.0/tool_ext/tool_BTS/dct_remoteserver D:\\dct_remoteserver"
    do_svn_checkout(cmd)


def create_tm500():
    TM500_install_path = find_TM_path()[0]
    DATALOG_path = TM500_install_path + "\\ftp_root\LOG\DATALOG"
    CMD_path = TM500_install_path + "\\ftp_root\LOG\CMD"
    if not os.path.exists(DATALOG_path):
        os.makedirs(DATALOG_path)
    if not os.path.exists(CMD_path):
        os.makedirs(CMD_path)
    cmd = "svn co --username ziqli --password Tp312ja05i http://svni1.access.nokiasiemensnetworks.com/isource/svnroot/" \
          "dcm_iv_ws/trunk/IVLRC3G_Robot_R1.0/tool_ext/tool_UESIM/tm500_remoteserver D:\\tm500_remoteserver"
    do_svn_checkout(cmd)


def create_rnc():
    rnc_log_path = "D:/Automation_LOG"
    if not os.path.exists(rnc_log_path):
        os.makedirs(rnc_log_path)

    dev_t = get_device_type().lower()
    if dev_t == 'artiza':
        cmd = "svn co --username ziqli --password Tp312ja05i http://svni1.access.nokiasiemensnetworks.com/" \
              "isource/svnroot/dcm_iv_ws/trunk/IVLRC3G_Robot_R1.0/tool_ext/tool_RNCSIM/artiza_remoteserver " \
              "D:\\artiza_remoteserver"
    else:
        cmd = "svn co --username ziqli --password Tp312ja05i http://svni1.access.nokiasiemensnetworks.com/" \
              "isource/svnroot/dcm_iv_ws/trunk/IVLRC3G_Robot_R1.0/tool_ext/tool_RNCSIM/srac_remoteserver " \
              "D:\\srac_remoteserver"
    do_svn_checkout(cmd)


def para_config():
    pc_type = 'unknown'
    try:
        pc_type = get_pc_type()
        eval('config_%s()' % pc_type)
        eval('create_%s()' % pc_type)
    except Exception, e:
        import traceback
        print traceback.format_exc()
        print "current pc type %s, error_info %s" % (pc_type, e)


if __name__ == '__main__':
    ip_num = get_lab_interface()
    gateway_ip = get_lab_interface_gateway()

    commands = ['cd Users\upl1-tester', 'echo succeed > callback_succeed.txt', 'cd Autoinstall_Status',
                'echo succeed > %s.txt' % ip_num]

    if not isUserAdmin():
        print "You're not an admin."
        runAsAdmin()
    else:
        print "You are an admin!"
    os.system("netsh interface ip add dns LAB 10.68.152.123 2")
    time.sleep(1)
    router_data = "route add 87.254.208.80 mask 255.255.255.255 %s " % gateway_ip
    os.system(router_data)
    time.sleep(1)

    para_config()
    do_telnet(Host, commands)
