import logging
from flask import Flask, request, make_response

app = Flask(__name__)

# 设置日志配置
handler = logging.FileHandler("app.log")  # 或者使用StreamHandler输出到控制台
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
app.logger.addHandler(handler)
app.logger.setLevel(logging.INFO)  # 根据需求调整日志级别



@app.route('/')
def sys_status():
	return 'server starts-up successful!'


@app.route('/hello')
def hello():
    response = "<span class='red-text'>this is route /hello</span>"
    log_message = f"Route accessed: '/hello' with method {request.method}"
    app.logger.info(log_message)

    return response, 200

@app.route('/api/v1')
def api_v1():
    response = "<span class='red-text'>this is route /api/v1</span>"
    log_message = f"Route accessed: '/api/v1' with method {request.method}"
    app.logger.info(log_message)

    return response, 200

@app.route('/api/v2')
def api_v2():
    response = "<span class='red-text'>this is route /api/v2</span>"
    log_message = f"Route accessed: '/api/v2' with method {request.method}"
    app.logger.info(log_message)

    return response, 200

# /api/user,post请求,返回json格式数据,返回请求参数和方法
@app.route('/api/user', methods=['POST'])
def api_user():
    response = "<span class='red-text'>this is route /api/user</span>"
    log_message = f"Route accessed: '/api/user' with method {request.method},request.args: {request.args}"
    app.logger.info(log_message)

    return response, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0')