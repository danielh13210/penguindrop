from flask import Flask,request # type: ignore
import base64
import random
import json
import os,subprocess
app=Flask("PenguinDrop Controller")
privacy_mode=False
active=False
ready=False
accepted=None
docker_id=None

def generate_name(filename):
    path=os.path.join(os.path.expanduser("~"),"Downloads",filename)
    basename, ext = os.path.splitext(filename)
    num=1
    while os.path.exists(path):
        num+=1
        path=os.path.join(os.path.expanduser("~"),"Downloads",f"{basename} {num}{ext}")
    return path

@app.route("/privacy")
def is_privacy_mode():
    return json.dumps({"privacy_mode": privacy_mode})

@app.route("/set_privacy", methods=["POST"])
def set_privacy():
    global privacy_mode
    key=request.json.get("key","")
    if key == "":
        return json.dumps({"error": "Key is required"}), 400
    if key!= localhost_key.decode():
        return json.dumps({"error": "Invalid key"}), 401
    if type(new_mode := request.json.get("privacy_mode",privacy_mode))==bool:
        privacy_mode = new_mode
        return json.dumps({"privacy_mode": privacy_mode})
    return json.dumps({"error": "Invalid privacy mode"}), 400

@app.route("/startsend", methods=["PUT"])
def send():
    global active, accepted, filename
    if privacy_mode:
        return json.dumps({"error":"Not accepting files"}),401
    if active:
        return json.dumps({"error":"Another host is sending"}),503
    filename=request.json.get("filename","")
    if filename=="":
        return json.dumps({"error":"no filename"}),400
    active=True
    accepted=None
    subprocess.Popen(["./confirmation.sh",filename,localhost_key.decode()])
    return "{}",207

@app.route("/status")
def status():
    global active, ready, docker_id, docker_launcher
    if not active:
        return json.dumps({"error":"no active transfer"}),400
    if accepted is False:
        active=False
        return json.dumps({"status":"declined"})
    if accepted is True:
        if docker_id:
            return json.dumps({"status":"ready"}), 200
        if (exit_code:=docker_launcher.poll()) is not None:
            if exit_code != 0:
                active=False
                print("error: docker failed to launch")
                return json.dumps({"status":"failed"}),500
            docker_id=docker_launcher.stdout.read().strip().decode()
            if not docker_id:
                active=False
                print("error: docker failed to launch")
                return json.dumps({"status":"failed"}),500
            ready=True
        return json.dumps({"status":"accepted"})
    if accepted is None:
        return json.dumps({"status":"waiting"})
@app.route("/confirm",methods=["POST"])
def confirm():
    global accepted,active,ready,docker_launcher
    key=request.json.get("key","")
    if key=="":
         return json.dumps({"error":"key required"}),400
    if key!=localhost_key.decode():
         return json.dumps({"error":"invalid key"}),401
    accept=request.json.get("accept",None)
    if type(accept)==bool:
        accepted=accept
        if accept:
            try:
                ready=False
                docker_launcher=subprocess.Popen("docker run -d -p 6708:22 penguindrop-acceptor",shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
                return json.dumps({"status":"accepted"}),200
            except subprocess.CalledProcessError:
                active=False
                return json.dumps({"error":"failed to start docker"}),500
        else:
            return json.dumps({"status":False}),200
    else:
        return json.dumps({"error":"accept must be boolean"}),400

@app.route("/close", methods=["POST"])
def close():
    global active
    status=None
    if os.system(f"docker cp {docker_id}:/home/ubuntu/{filename} \"{generate_name(filename)}\"")!=0:
        active=False
        if not status: status=json.dumps({"status":"failed","error":"file save failed"}),500
    if os.system(f"docker stop {docker_id}")!=0:
        active=False
        if not status: status=json.dumps({"status":"partialfail","error":"docker stop failed"}),500
    if os.system(f"docker rm {docker_id}")!=0:
        active=False
        if not status: status=json.dumps({"status":"partialfail","error":"docker rm failed"}),500
    active=False
    if not status: status=json.dumps({"status":"done"})
    return status

if __name__ == "__main__":
    localhost_key=base64.b64encode(random.randbytes(256))
    print(f"localhost key: {localhost_key.decode()}")
    app.run(host="0.0.0.0",port=6707)
