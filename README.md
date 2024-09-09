# haquocbao.id.vn 🌐

**My porfolio!**

This repository contains **frontend** component's source code. _Backend_ component's source code should be found [here](https://github.com/hoangtu47/shell-backend.git).



// insert picture

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
