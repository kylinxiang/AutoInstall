import cmd_exec
import re
import os
import pickle
MMT_PATH = 'C:/BS3201_Tools/MMT/tshark.exe'
CFG_PATH = r'D:\IVLRC3G_Robot\configs\environment_parameter'


def get_mmt_port():
    intf_str = cmd_exec.execute_cmd('%s -D' % MMT_PATH)
    mmt_intf_list = re.findall(r'\((.*)\)', intf_str)

    ip_info = cmd_exec.execute_cmd('ipconfig /all')
    prog = re.compile('.*Description[^:]+: ([^\r\n]+).*?IP(v4)? Address.*?(192.168.129.190)',re.IGNORECASE|re.DOTALL)
    intf_desc = prog.match(ip_info).groups()[0]

    for i, desc in enumerate(mmt_intf_list):
        if intf_desc in desc:
            return i+1
    raise Exception("No interface is related to 192.168.129.190.")


def create_env_file(bts_ip):
    with open('d:/data.pkl', 'wb') as ot:
        pickle.dump(bts_ip, ot)
    src_file = os.path.join(CFG_PATH, 'bts_sample_env.txt')
    dst_file = os.path.join(CFG_PATH, 'bts_%s_env.txt' % bts_ip)
    print cmd_exec.execute_cmd('copy %s %s' % (src_file, dst_file))


def modify_para(k, v):
    with open('d:/data.pkl', 'rb') as it:
        bts_ip = pickle.load(it)
    env_file = os.path.join(CFG_PATH, 'bts_%s_env.txt' % bts_ip)
    with open(env_file, 'r') as env:
        env_paras = env.read()
    old_kv = re.findall('.*?([$@]\{%s\}\s+[^#\n]*)' % k, env_paras)[-1]
    new_kv = '%s{%s}    %s    ' % (old_kv[0], k, v)
    replaced_text = env_paras.replace(old_kv, new_kv.encode('utf8'))
    with open(env_file, 'w+') as env:
        env.write(replaced_text)