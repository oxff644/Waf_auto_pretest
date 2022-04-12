#!/usr/bin/python
#coding=utf-8

from __future__ import division
import logging
import os,sys,time,socket,threading,copy,StringIO,cPickle,subprocess,fcntl,struct,signal,shutil,commands,logging,datetime,json,platform,re
import re,ConfigParser
import time
#import redis
import Queue
import thread


# 传参：waf版本 域名 并发数 重复次数 测试数据 唯一id

work_dir = "/usr/local/waf_test/"
nginx_work_dir = "/usr/local/nginx/conf/servers/"
logging.basicConfig(filename = work_dir + "logs/waf_test.log",level = logging.INFO, filemode = 'a', format = '%(asctime)s - %(levelname)s: %(message)s')
data_dir = work_dir + "datas/"
worker_num = int(sys.argv[3])
exit_worker = 0
status_list={}
total_num=0
ok_num1=0
err_num=0
use_time=0
q = Queue.Queue(maxsize = 0)
lock=threading.Lock()
host = sys.argv[2]
repeat_time = int(sys.argv[4])
guid = sys.argv[6]
mode = sys.argv[7]
count=0
qps=[]
requests_info = {}
data_len = 0
for i in range(0, worker_num):
    requests_info[i] = Queue.Queue(maxsize = 0)

def main():
    global use_time
    global start
    #file_path=sys.argv[1]
    ip='115.54.16.68'
    init_data_list() # 初始化数据
    #sock=connect_web(ip)
    start_time=time.time()
    start = time.time()
    init_work_list(ip)
    #do_replay(sock,file_path,ip)
    while 1:
        if exit_worker == worker_num:
            break
        time.sleep(1)
    end_time=time.time()
    use_time= end_time - start_time
    play_summary(use_time)


def init_data_list():
    all_request = []
    try: 
        dir_list = os.listdir(data_dir)
        if not dir_list:
            return
        else:
            for file_name in dir_list:
                split_num = 0;
                request_data=""
                #print file_path
                file_path = data_dir + file_name
                with open(file_path,"r") as f:
                    for line in f.readlines():
                        if line=="====****\n":
                            #print re.sub("Host:.*\r\n","Host: www.linsd.com\r\n",request_data)
                            #send_http_request(request_data,ip) 
                            #for i in conf_list:
                            i = "botsec.haplat.net"
                            url = "http://" + i + "/"
                            request_data = re.sub("http[s]?://(.+?)/",url,request_data)
                            #request_data = re.sub("http://(.+?)/",url,request_data)
                            host_name = "Host: "+ i + "\r\n" 
                            #print host_name
                            request_data = re.sub("Host:.*\r\n",host_name,request_data)
                            #print request_data
			    #print request_data
                            all_request.append(request_data) 
                            #request_data = request_data + "###@@@"
                            #total_num=total_num+1
                            #split_num = split_num + 1
                            #if split_num == 100:
                            #   thread.start_new_thread(replay_work, (ip,request_data))
                            #   split_num = 0
                            request_data = ""
                        else:
                            request_data = request_data + line
    except Exception, e: 
        logging.error(e)
         
    for i in range(0, repeat_time):
        request_num = len(all_request)
        for j in range(request_num):
            for k in range(0, worker_num):
                requests_info[k].put(all_request[j])

    time.sleep(1)


def init_work_list(ip):
    for i in range(worker_num):
        thread.start_new_thread(replay_work, (ip,"", i))

def replay_work(ip,data, worker_id):
    global exit_worker
    global lock
    global ok_num1
    global qps

    while requests_info[worker_id].empty() == False:
        try:
            request_data = requests_info[worker_id].get()
            send_request(request_data,ip,worker_id)
        except Exception, e:
            logging.error(e)
    if requests_info[worker_id].empty():
        print "no requests"
    if lock.acquire():
        exit_worker=exit_worker+1
        lock.release()


def fPopen(aCmd):
    p=subprocess.Popen(aCmd, shell=True, bufsize=4096,stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True)
    sOut = p.stdout.read()
    sErr = p.stderr.read()
    return (sOut,sErr)

def send_request(data,ip,worker_id):
    global ok_num1
    global err_num
    global status_list
    global lock
    global end
    global start
    global data_len
    try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 
            sock.connect((ip, 80))
            http_request = data
            sock.send(http_request)
            rev_data = sock.recv(1024)
            status = rev_data[9:12]
            #print status
            if lock.acquire():
                ok_num1 += 1
		data_len += len(data)
		#print ok_num1
                if ok_num1 == 100000:
                    end = time.time()
                    Qps = 100000/(end - start)
                    s = 'data_len:' + str(data_len) + 'start:' + str(start) + ' end:' + str(end) + ' qps:' + str(Qps)
		    print s
                    qps.append(s)
                    ok_num1 = 0
                    start = time.time()
		    data_len = 0
                lock.release()
            sock.close()
    except socket.error, msg:
            err_num=err_num+1
            logging.error(msg)
    except Exception, e:
            err_num=err_num+1
            logging.error(e)


def play_summary(use_time):
    with open(work_dir + 'analysis/' + guid + '-' + mode + '/report.txt', 'w') as f:
        for element in qps:
            f.write(str(element) + '\n')
    # print "total_num: " + str(total_num)
    print "ok_num1: " + str(ok_num1)
    print "err_num: " + str(err_num)
    print "use_time: " + str(use_time)
	
if __name__ == "__main__":
    main()
    sys.exit(0)
