#!/usr/bin/python
#coding=utf-8

import logging
import os,sys,time,socket,threading,copy,StringIO,cPickle,subprocess,fcntl,struct,signal,shutil,commands,logging,datetime,json,platform,re
import re,ConfigParser
import time
#import redis
import Queue
import thread



work_dir = "/usr/local/waf_test/"
nginx_work_dir = "/usr/local/nginx/conf/servers/"
logging.basicConfig(filename = work_dir + "logs/waf_test.log",level = logging.INFO, filemode = 'a', format = '%(asctime)s - %(levelname)s: %(message)s')
data_dir = work_dir + "datas/"
worker_num = 5
exit_worker = 0
status_list={}
total_num=0
ok_num=0
err_num=0
use_time=0
q = Queue.Queue(maxsize = 0)
lock=threading.Lock()
conf_list=[]

def main():
    global use_time
    #file_path=sys.argv[1]
    ip=sys.argv[1]
    init_conf_list()
    init_data_list()
    #sock=connect_web(ip)
    start_time=time.time()
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
    try: 
        dir_list = os.listdir(data_dir)
        if not dir_list:
            return
        else:
            for file_name in dir_list :
                q.put(data_dir + file_name)
    except Exception, e: 
        logging.error(e)
         
    time.sleep(1)

def init_conf_list():
    global conf_list
    try:
        dir_list = os.listdir(nginx_work_dir)
        if not dir_list:
            return
        else:
            for file_name in dir_list :
                server_name = file_name[:-5]
                conf_list.append(server_name)
    except Exception, e:
        logging.error(e)


def init_work_list(ip):
    thread.start_new_thread(replay_work, (ip,""))
    thread.start_new_thread(replay_work, (ip,""))
    thread.start_new_thread(replay_work, (ip,""))
    thread.start_new_thread(replay_work, (ip,""))
    thread.start_new_thread(replay_work, (ip,""))

def replay_work(ip,data):
     global exit_worker
     global lock
     
     while q.empty() == False:
         try:
             file_path = q.get()
             do_replay(ip,file_path)
         except Exception, e:
             logging.error(e)
     print "no file"
     if lock.acquire():
          exit_worker=exit_worker+1
          lock.release()

def do_replay(ip,file_path):
    global total_num
    split_num = 0;
    request_data=""
    print file_path
    with open(file_path,"r") as f:
        for line in f.readlines():
            if line=="====****\n":
                #print re.sub("Host:.*\r\n","Host: www.linsd.com\r\n",request_data)
                send_http_request(request_data,ip)    
                #request_data = request_data + "###@@@"
                #total_num=total_num+1
                #split_num = split_num + 1
                #if split_num == 100:
                #   thread.start_new_thread(replay_work, (ip,request_data))
                #   split_num = 0
                request_data = ""
            else:
                request_data = request_data + line


def fPopen(aCmd):
    p=subprocess.Popen(aCmd, shell=True, bufsize=4096,stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True)
    sOut = p.stdout.read()
    sErr = p.stderr.read()
    return (sOut,sErr)

def send_http_request(request_data,ip):
    for i in conf_list:
        url = "https://" + i + "/"
        request_data = re.sub("https://(.+?)/",url,request_data)
        host_name = "Host: "+ i + "\r\n" 
        #print host_name
        request_data = re.sub("Host:.*\r\n",host_name,request_data)
        #print request_data
        send_request(request_data,ip)


def send_request(data,ip):
    global ok_num
    global err_num
    global status_list
    global lock
    try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 
            sock.connect((ip, 9101))
            http_request = data
            sock.send(http_request)
            rev_data = sock.recv(1024)
            status = rev_data[9:12]
            print status
            if lock.acquire():
                if status_list.has_key(status):
                    status_list[status]=status_list[status] + 1
                else:
                    status_list[status]=1
                ok_num=ok_num+1
                print str(ok_num)
                lock.release()

            sock.close()
    except socket.error, msg:
            err_num=err_num+1
            logging.error(msg)
    except Exception, e:
            err_num=err_num+1
            logging.error(e)		
def play_summary(use_time):
    print status_list	
    print "total_num: " + str(total_num)
    print "ok_num: " + str(ok_num)
    print "err_num: " + str(err_num)
    print "use_time: " + str(use_time)
	
if __name__ == "__main__":
    main()
    sys.exit(0)
