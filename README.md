# [haquocbao.id.vn](https://haquocbao.id.vn) 🌐

**My porfolio!**

This repository contains **frontend** component's source code. _Backend_ component's source code should be found [here](https://github.com/hoangtu47/shell-backend.git).

![image](https://github.com/user-attachments/assets/92f5c6bf-7b5f-4d27-8d9a-b62e080946fa)
![image](https://github.com/user-attachments/assets/1aab3e2a-72b8-4187-918f-68ee12356866)


# Structure

Follows **Microservice** architecture. This whole application is a **collection of services** that are **independently deployable** and **loosely coupled**. 

- The service serving as the frontend and that of the backend are **separate** into two repositories, having its own **independent** and **asynchronous** CD/CI workflow. 
- Those two services are coupled through only **a single WebSocket connection**.

![Architecture diagram](https://github.com/user-attachments/assets/9bbf9ff7-f510-4a8d-8b56-351bde6fa586)

Under the hood, the **Serverless** infrastructe offered by _**AWS**_ and _**Azure**_ is provided on-demand.

# Tech Stack

- **SvelteKit** framework.
- **WebSocket**. 🔌
- **XtermJS** to emulate terminal.
- **AWS Amplify** for CD/CI.
