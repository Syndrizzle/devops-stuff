# DevOps Stuff

<img src="https://www.jenkins.io/images/logos/nerd/nerd.svg" width="150">

Welcome to the devops-stuff repository! Here you'll find information on how to do certain simple things in Jenkins, such as configuring nodes, plugins, creating pipelines, and much more :)

### Setting Up Jenkins
#### 📦️ Installing Jenkins

The first and the foremost step is to install Jenkins, there are plenty of ways to do it. 
The easiest way, is to use the script provided in this github repository.
A few things to consider before running this script:
- This script is **only meant for linux and macos**, if you are using windows, please visit the [Installing Jenkins On Windows](https://www.jenkins.io/doc/book/installing/windows/) page
- You'll need `curl` on your system before you can run this script.
- This script is only mean to install or uninstall jenkins locally, if you plan on giving your jenkins instance remote access, you'll have to do that manually.

With that in mind, open a terminal and run this command:

```bash
curl -sSL -o jenkins.sh https://raw.githubusercontent.com/Syndrizzle/devops-stuff/refs/heads/main/jenkins.sh
chmod +x jenkins.sh
```

This will download the script in your current working directory, and give it executable permissions. Finally, run the script with the following command:

```bash
./jenkins.sh
```

1. You'll be presented with a prompt asking you to choose between installing or uninstalling jenkins. Since this is our first time, you'll likely go with the first option.
2. Next, you'll be asked whether to choose an LTS release or a weekly release, it is recommended to go with the LTS version, as it is more stable and you're likely to run less into issues.
3. You'll be prompted to enter your 🔒️ superuser (sudo) password, after which the installation should begin.
4. It might take a while, sit back and relax, or make some [coffee](https://moribyan.com/einspanner-vienna-latte/).
5. Once that's done, you'll be asked to start the jenkins service, and open it into the browser, thus saving you a few clicks.
	- By default, the script opens the webserver at `localhost:8080`, but on some systems, such as `arch`, the webserver runs at `localhost:8090`, so please change it accordingly.
6. The script also prints the Initial password to unlock jenkins, just copy it and paste it into the webserver which will ask you about it.
7. In the end, this is how a successful script run might look like:

	![Image](assets/1.png)

If you see something similar, congratulations! You have successfully installed jenkins, we can safely proceed to the next step!

#### ⚙️ Initial Setup

When you are done with entering the admin password, you'll be greeted with a screen asking for installing recommended plugins or manually selecting plugins to install with, in most scenarios, you are likely to go with the recommended plugins options, since you can manage your plugins later, which we will see how to later in this session.

⌚️ Wait for them to install, it might take a while.

After that's done, you'll be asked to create a first admin user. It is recommended to create a user rather than continuing as admin. Regardless, if you wish to continue as an admin, the username will be `admin` and the password will be `admin` as well.
As for creating the user:
- **Username:** This will be your admin user's username. 
- **Password:** This will be your admin user's password. Keep it something you'll remember.
- **Full Name:** This should be your admin user's full name, as the title suggests.
- **Email:** This should be your admin user's email. It is generally recommended to have one, so it can send you emails and stuff. We will learn more about it later.

Next, you'll be asked about the jenkin's URL, you have two options:
- If you are running jenkins locally, keep it as it is.
- If you plan on deploying your jenkins at a remote server available for public viewing, you can set it to a domain or IP through which it will be accessible. For ex. `https://jenkins.syndrizzle.me` is where my jenkins runs. Where `syndrizzle.me` is the domain name and `jenkins` is the subdomain.

Next, you can click Finish, after which your jenkins should be ready! 🎉

### Managing Jenkins

After your initial setup, you'll be thrown into the jenkins dashboard. do not fret! It might look confusing, but over time you'll get comfortable with it.
There's a `Manage Jenkins` button on the left sidebar, we'll start from there.

#### 📦️ Installing Plugins

Let's start with the fun part, installing some handy jenkins plugins! These will supercharge how you use jenkins.
Ignore any warnings for now, you might see one or two, one of which being the `Building on the built-in node can be a security issue`, we will get back to it in a moment.

For now, click on the `Plugins` option, and that should throw you to the plugins page. You can manage your updates, install new plugins, check any errors about the existing plugins, enable or disable your plugins, all from this page. 
For now, click on the `Available Plugins` in the sidebar, and install some plugins listed below:
- **[Eclipse Temurin installer Plugin](https://plugins.jenkins.io/adoptopenjdk)**: This will allow us to install and manage multiple java versions, all from jenkins itself.
- **[Git Parameter Plug-In](https://plugins.jenkins.io/git-parameter)**: This plugin will allow us to configure git branch parameters while triggering a pipeline build, so you will be presented from what branch you wanna trigger the build.
- **[GitHub Integration Plugin](https://plugins.jenkins.io/github-pullrequest)**: As the title says, it is a Github Integration Plugin :)
- **[Role-based Authorization Strategy](https://plugins.jenkins.io/role-strategy)**: This plugin will enable us to manage role based authorization in jenkins, really handy for team workspaces.
For now, these will do, you can explore more plugins and their uses in the `Available Plugins` tab, there are plenty of them!

When you are done with the selection, press the big blue Install button, and that'll take you to the `Download Progress` screen, which shows you the status of the plugins. Scroll down, and after everything seems to be a ✅ Success, click the `go back to the top page` button, which will take you to the homepage again.

That's it! It is really that easy to install and manage plugins! Do keep in mind that Jenkins plugin updates are frequent, so make sure to check that tab frequently and give your plugins some updates once in a while 😉


#### 👥 Role Based Authorization

When working in a team on a project, you might often want to distribute the workload, and divide the permissions just to keep things streamlined, during which, the `Role-based Authorization Strategy` plugin comes in handy, as it allows us to distribute permissions across different user roles, so they can manage what they are assigned. This is similar to how [IAM works in Amazon Web Services](https://aws.amazon.com/iam/).

Lets start with how to setup role based strategy:
- Again, go to the `Manage Jenkins` page from the sidebar.
- This time, we will visit the `Security` page, this allows us to change the permissions of the system.
- Once inside, change the Authorization to `Role Based Strategy` and hit save.

	![Image](assets/2.png)

- Hit `Save`, and that's it, your Jenkins is now configured to follow a Role Based Authorization.

##### Creating a Test User

Before we dive into managing and testing roles, we will create a test user to experiment with the permissions. 
Follow the steps below to create a user:
- Go to `Manage Jenkins` > `Users`
- By default, there will only be one user i.e. your own admin user, click on the `Create User` button to add your test user.
	![Image](assets/3.png)
- Fill in the credentials for your test user, and click on the create one.
	![Image](assets/4.png)
##### Understanding Roles

When you are done setting up the role based authorization, you'll see a new page option to appear under `Manage Jenkins` page. It is called `Manage And Assign Roles`, this page will be used to configure your roles and assign them permissions.

Clicking on that option will take you to a page where you'll see a default role admin, with a tabular set of permissions. There are a different set of permissions for everything, these include but are not limited to:
- **Global Roles:** These roles are assigned and configured jenkins-wide. Meaning any role created or assigned permissions here, will have permissions across the whole jenkins system.
- **Project Roles:** The project roles are only assigned to a certain project, you're likely to use this one, since you'll assign roles per project.
- **Agent Roles:** These are used to set node related permissions.
- You can also use [Macros](https://github.com/jenkinsci/role-strategy-plugin/blob/master/docs/MACROS.md) to manage your roles in a more modular way. But this is for advanced permissions, which are not covered here.

##### Creating Roles

It's time, to create some roles! Seriously this is the part which you might or might not love to do, but it is something you'll have to consider using at some point, so better know it right now 😁

Lets start with the **Global Roles.**
- Under the `Role to add` option, create a role, give it a name, let's say `employee`, and click on add.
- You'll see the table now lists two roles, one of which has no permissions, you'll need to assign them to that role, for starters, here's our permissions that we are gonna give to this role:
	- **Overall:** `Read`
	- **Job:** `Build`, `Configure`, `Create`, `Delete`, `Read` and `Workspace`
	- **Run:** `Update`
	- **SCM:** `Tag`
- Your global roles table should look somewhat like this now:
	![Image](assets/5.png)


Next, let's configure the **Item Roles**.
Here, you are supposed to provide a role, along with a project pattern that'll assign all the project configured permissions to that role. For writing patterns, you can follow the traditional [Regular Expressions](https://en.wikipedia.org/wiki/Regular_expression) syntax.

For starters, let's make two roles:
1. Project Admin
2. Project Developer

Project admin will, obviously have more permissions than the project developer. We will use an example pattern, `Java_.*` to match the job titles. For example, this role will be assigned to users working with Jobs / Projects such as `Java_App`, `Java_Pipeline`, `Java_YadaYada` etc.

Create the roles and assign them the following permissions:
- For `project-admin`: 
	- **Job:** `Build`, `Configure`, `Create`, `Delete`, `Read` and `Workspace`
	- **Run:** `Update`
	- **SCM:** `Tag`
- For `project-developer`:
	- **Job:** `Build`, `Read`
	- **Run:** `Replay`
- Once done, this is how your table should look like:
	![Image](assets/6.png)

With that, we can move to assigning these roles.

##### Assigning Roles

Once we are done creating the roles, we can assign these roles to our teams / users.
Click on the `Assign Roles` in the left sidebar. You'll see a similar tabular structure as it was while we created the roles.

- Assigning **Global Roles**:
	- Here, you'll see your own user being marked as admin. We need to add our test user we created.
	- Cick on the `Add User` button, and type in the username of the created test user, in my case, it was `testuser`. 
	- You will see instead of saying `testuser`, it says the user's full name, which means Jenkins has recognized your specified user.
	- Now, we will grant this user the employee status, which will give them only the specified permissions in your jenkins infrastructure.
	![Image](assets/7.png)
	
- Assigning **Item Roles**:
	- Similar to assigning global user permissions, you can also assign per project roles to a user. 
	- Scroll down to Item Roles and click on the `Add User` button.
	- In my case, it was `testuser`, so I will type that name, and assign the `project-admin` role to my user.
	- This will provide the `project-admin` permissions to my `testuser` user, which means they will be able to manage all the projects / jobs started with `Java_` as the admin of those jobs.

With that, you are done with the role based authorization basics, you can explore and create complex roles, and assign them to the users and groups, existing on your infrastructure. This way, your jenkins stays safe, and you can distribute roles.

#### 🛠️ Managing Tools

While using jenkins, you will utilize a lot of tools, there are all but not just limited to `Gradle`, `Maven`, `SCM`, `Java` etc.
Jenkins comes with a nice handy page for managing all of these at one location! Saving you a lot of hassle. With this method, you can have multiple versions of tools under different names, which you can specify in your jobs, to make your builds seamless. In this tutorial, we will learn how to configure different `Java` and `Maven` versions.

1. Click on the `Manage Jenkins` button on the left sidebar at homepage.
2. Visit the `Tools` page, from here, we will add or manage our tools.

##### Installing Java

First, we will start with installing `Java`. Since we installed a plugin earlier to download Java automatically, we will be utilizing that. 
	1. While being in the tools page, scroll down and you'll find an option for managing `JDK Installations`.
	2. Click on the `Add JDK` button.
	3. Give your JDK version a name. Since we are installing `Java 17` here, we will give it that name.
	4. Now, click on the `Install automatically` checkbox.
	5. From the `Add Installer` dropdown menu, select `Install from adoptium.net`.
	6. Another dropdown menu will appear, this time listing all the respective JDK versions, select `jdk-17.0.13+11`, which is the latest Java 17 version at the time of writing this.
	7. You can repeat the same steps to add more Java versions, by clicking the `Add JDK` button, such as `Java 21`, `Java 8`, and so on.
	8. Once done, click on `Apply`, since we are not done yet.

##### Installing Maven

For building any java applications, we will be needing `Maven`. Jenkins has built in support for downloading and configuring different maven versions, which is what we will be using.
	1. Scroll down under the same tools page, and you'll be presented with `Maven Installations`.
	2. Click on the `Add Maven` button.
	3. Give your maven version a name, in this case, we will be naming it `Maven 3.9.9`, since 3.9.9 is the latest version at the time of writing this.
	4. That's it, jenkins automatically selects the latest version for you, so you don't have to configure anything else.
	5. Similar to this, you can add multiple maven versions, through the `Add Maven` button.
	6. With that done, click on `Save`.

#### 🖥️ Managing Nodes

Now, we come to the part where we saw that big yellow warning, while initially opening the `Manage Jenkins` page. 

##### Understanding Nodes

Understanding nodes can be deep and a challenging task, but in layman's terms, here's what the different things do:
- **The Jenkins Controller:** The Jenkins controller is the main part of Jenkins that runs on your server. It's like the "brain" of Jenkins. It makes decisions about when and where to run tasks. The controller also handles things like settings, security, and managing jobs. It serves web pages for you to interact with Jenkins and stores files created by jobs.
- **Nodes**: Nodes in Jenkins are the machines where your tasks (like builds) actually run. Jenkins keeps track of each node’s health, checking things like disk space and response times. If a node has issues, Jenkins can take it offline. There are two types of nodes:
	1. **Agents**: These are separate machines that run tasks.
	2. **Built-in node**: This is part of the Jenkins controller itself. While you _can_ run tasks on it, it's not recommended because it can cause security and performance problems.
- **Agents**: Agents are small programs that run on separate machines and do the work for Jenkins. They connect to the main Jenkins server and run tasks (like building software). Each agent has its own tools and software needed to do the work, and can run in a normal setup or in a container like Docker.
- **Executors**: An executor is like a "job slot" on an agent. It lets the agent run tasks. The more executors a machine has, the more tasks it can handle at the same time. But you need to make sure the machine has enough resources (like CPU and memory) to handle multiple tasks without slowing down.
With that in mind, let's add a new Agent for us to use.

##### Setting up your Node

For this tutorial, we will be using an [EC2 Instance](https://aws.amazon.com/ec2/) from [Amazon Web Services](https://aws.amazon.com) to create and manage our jenkins node. You can get a free instance under AWS Free Tier. I am not covering on how to create an EC2 instance in this tutorial, you can refer to [Creating an EC2 Instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html) on the AWS Documentation. 
Just keep a few things in mind when creating the instance, as this will make it easier to understand what's happening:
- Use the Ubuntu AMI, instead of Amazon Linux, as it is generally easier to use and setup, and is also, more universal.
- Create a keypair to connect to your instance, you'll also need this keypair for connecting jenkins to this instance.

![Image](assets/8.png)
With that done, and having an EC2 instance up and running, we can set things up:
- SSH Into your instance using your desktop.
	- Copy the public IPv4 address of your instance.
	- Open a terminal and type `ssh -i keypair.pem ubuntu@server-ip`, where:
		- `keypair.pem` is the keypair that you created and downloaded while creating the instance. Run this command in the directory where you created your keypair.
		- `server-ip` is the IPv4 address of your EC2 instance server.
	- If all goes well, you'll be asked to continue connecting, type `yes`.
	- If somehow you get greeted with a text message saying `Permissions for keypair.pem are too open`, just run `chmod 600 keypair.pem` to fix the permissions, and rerun the SSH command.
- Configure Jenkins related dependencies
	- We need Java - `sudo apt install openjdk-17-jdk`
	- You'll need to specify a working directory for jenkins, in best cases, it is recommended to use some directory that is easily accessible and widely known, in this case, we will be using `/var/jenkins`.
		- Create the directory using `sudo mkdir -p /var/jenkins`
	- You'll need to give access to this directory to jenkins, since we will be using the same credentials as our SSH instance, i.e. `ubuntu`, we will neeed to give the ubuntu user access to this directory:
		- Run `sudo chown ubuntu:ubuntu /var/jenkins` to give that user permissions to access that folder.
		- **NOTE:** It is generally not recommended to run jenkins on the standard user, you'll likely want to create a jenkins user with it's own set of permissions. As for the tutorial purposes we will be proceeding with the ubuntu one, however, if you'd like to create a jenkins user:
			- Create the `jenkins` group:
				`sudo groupadd jenkins`
			- Create the `jenkins` user and assign it the `jenkins` group:
				`sudo useradd -m -d /var/jenkins -s /bin/bash -g jenkins jenkins`
			- Setup permissions for the `/var/jenkins` directory:
				`sudo chown -R jenkins:jenkins /var/jenkins`
	- With that, you are done configuring all the jenkins related tasks on your EC2 instance, now, head over to your Jenkins Dashboard to utilize this Node.

##### Connecting Node to Jenkins

Alright, now since we are done configuring every Jenkins related roadblocks on our EC2 instance, we can now let Jenkins configure this agent.
- To do so, navigate to `Manage Jenkins` > `Nodes`
- Here, you'll see a Big Blue button that says `New Node` , click on that.
- Oh this page, it'll ask you for the **Node Name**, and whether the node should be permanent or not, I'd like to add this as a permanent node. Give it a name, and click `Create`.
- Give it a **Description** if you want to.
- **Number of executors:** As described above in the `Understanding Nodes` section, these executors are meant to run a specified number of jobs on this node, think of this as a worker in a factory, the more the workers, the faster is the tasks are done. For the purposes, we will set it to `5`.
- **Remote root directory:** Here, we will specify where our jenkins agent will be doing it's magic, as we created `/var/jenkins` earlier, we will specify that here.
- **Labels:** You can give this node multiple labels, separated by space. Labels are tags, which you will be using to distinguish multiple nodes from each other, for example, if you have 3 nodes with different java versions for different projects, you might want to set some tags like `java-8`, `java-17` or `java-21` for each of those nodes. With that, you can specify which node to build the project at.
- **Launch Method:** Here, we will select `Launch agents via SSH`. Now, it will ask you for the Host information, fill in the details accordingly.
	- **Host:** Here goes the IP Address of your EC2 Instance.
	- **Credentials:** Here, you will need to specify the user (`ubuntu`) and the `keypair.pem` file so that jenkins can connect to it. 
		- Click on the `Add` button, and select `Jenkins`
		- In kind, select `SSH Username with private key`
		- Specify an ID for these credentials, this act like a name to it. For the purposes I am specifying `aws-credentials`.
		- In username, fill in the `ubuntu` (or `jenkins` if you followed the steps to make the jenkins user) username.
		- In `Private Key`, check the `Enter directly` box. Now, take out the content of the `keypair.pem` file on your PC, for example, with `cat keypair.pem`, and paste it there by clicking the `Add` button. It should be look like this:
		 ```
			  -----BEGIN RSA PRIVATE KEY-----
			  ... Keypair content ...
			  -----END RSA PRIVATE KEY-----
		```
		
- Select the credentials from the dropdown menu.
- **Host Key Verification Strategy**: Here, select `Non verifying Verification Strategy` from the dropdown menu.
- Click on the `Save` button or go through any other settings if you feel like they're worth checking out.

Now, we will need to start the node:
- You will be taken back to the managing nodes screen.
- Click on the 🔄 Refresh button located on top right.
- If all goes well, the N/A fields should populate with information. You might see a red warning which says the clock for the agent is a bit ahead, which is alright.
- If you don't see the fields being populated, click on the node and click the big blue `Relaunch Agent` button.
- If there are any errors, check the console for logs.

With this, you have successfully added a Node to jenkins 🎉

### Examples

#### 📀 Pipeline to execute Shell Scripts

Now, with all that learnt, it is time to create your first job on Jenkins!
We will be using a few shell scripts in this test, located in this very github repository, under `example-script-pipeline/examples` folder. The first one is a `process_monitor.sh`, as the name says, it will monitor your processes when the job runs, and it will display the top 5 CPU utilizing applications. The second script is the `disk_check.sh`, which will monitor the disk usage and report it if the disk usage is above 80%.

1. For getting started, click on the `New Item` button on the sidebar at homepage.
2. Here, give your project a name, select `Pipeline` and click `OK`.
3. Give it a description if you want to.
4. Now, specify a project URL to your pipeline, in this case, we will specify this repository's URL: `https://github.com/Syndrizzle/devops-stuff`. This URL is visible on the Pipeline page sidebar, giving you easy access to the repository.
5. Now, scroll down and and stop at the Pipeline configuration.
6. Here, select `Pipeline script from SCM` under `Definition`. This will allow us to pull a `Jenkinsfile`, which is used for writing pipeline configuration, from this repository. You can read more about a [`Jenkinsfile and it's syntax here`](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/). Now specify the following:
	- Select `Git` as your `SCM` provider.
	- Under `Repository URL`, give this repository's URL.
	- You don't need to select any credentials, as this is a public repository. However, you might want to add credentials for private Git repositories.
	- Now, under branches to build, change `*/master` to `*/main`, since our repository uses the `main` branch as it's `HEAD`.
	- Under `Script Path`, specify `example-script-pipeline/Jenkinsfile`, since our `Jenkinsfile` for running these scripts is located in the `example-script-pipeline` folder.
7. Click on `Save`.
8. Click the `Build Now` button on the left sidebar. You'll see a notification and a build `#1` to appear in the Builds sidebar.
9. If all goes well, you will see a green checkmark ✅ on the build, which means the pipeline execution was successful. You can now click on the build, and navigate to `Console Output` to view the build logs (And to check if the scripts worked).

That's it, this was an example on executing shell scripts through jenkins, you are not limited to anything here, as you can automate almost anything! It's all about the right tool for the right job 😉

Things to note:
- This script sets up a cron job to run the script at hourly intervals, so as to monitor the disks. The cron syntax would be `H * * * *`, you can view and edit it by configuring the Pipeline. You can read more about cron jobs here and how to write one, [here](https://crontab.cronhub.io/).
- Take a look at the [`Jenkinsfile`](https://github.com/Syndrizzle/devops-stuff/blob/main/example-script-pipeline/Jenkinsfile) of this test, scrolling down you'll find a section where it send's an email if the job somehow fails. The email wouldn't obviously, work, since the email configuration is missing. Read more about [emails on jenkins here](https://plugins.jenkins.io/email-ext/).

#### 📀 Pipeline to build a Java App

Now with shell scripts being out of the way, it is time to do some real building over Jenkins! In this tutorial we will be building a simple java app, [provided by Jenkins themselves](https://github.com/jenkins-docs/simple-java-maven-app). The java app is also located [in this repository](https://github.com/Syndrizzle/devops-stuff/tree/main/example-app-pipeline), with a tweaked [`Jenkinsfile`](https://github.com/Syndrizzle/devops-stuff/blob/main/example-app-pipeline/Jenkinsfile). 
You can take a look at the jenkinsfile, let's figure out what's happening here:
- The `timeout()` function is responsible for managing how long the job should run, in this case, it is configured to be able to run for `10 minutes`, after which it will automatically terminate itself.
- The `tools` section allows you to specify the tools for building this pipeline, since we configured two of these tools already, which are `Java 17` and `Maven 3.9.9`, Jenkins will use these to build this app.
- The `triggers` is where your magic happens, if you are having this app deployed on github, the `githubPush()` function is responsible for utilizing the [GitHub Webhooks](https://docs.github.com/en/webhooks) for automatically triggering a build if a commit occours. Similarly, the `pollSCM()` function runs a cron test.
- The `parametrs` section allows us to specify build parameters, in this case, since we are using the `Git Parameter Plug-In`, as we configured previously, it will allow us to select the available branches to trigger the build from.
- The `stages` section allows you to specify different stages in the build process, here we are using 3 different stages:
	- **Build:** To build the app using Maven.
	- **Test:** To run tests on the app, using Maven.
	- **Deliver:** To build the binary and publish the artifacts.
- The final section, `post`, allows us to specify post execution tasks, such as sending a notification, cleaning up the workspace, etc.

With that in mind, we can now start with the configuring procedure:
1. Create another pipeline with the `New Item` button, give it a name and a description.
2. Again specify the `GitHub Project URL` to be this repository. 
3. Now, we will need to configure the parameters to specify while building this app, since we are using the `Git Parameter Plug-In`, click on the `Add Parameter` and select `Git Parameter`.
	- Give your parameter a name, most suitably `Branch`.
	- Give it a description if you want to, such as `Choose the specified Git Branch to build from.`
	- Select the parameter type from the dropdown, for the purposes we will be going with `Branch`.
	- Specify a default branch, which will be selected when you are prompted to select the branch, here, since there's only one branch called `main`, specify the default branch to be `origin/main`.
4. Scroll down and under `Build Triggers`, select `GitHub hook trigger for GITScm polling`, this will allow us to trigger builds through GitHub commit push.
5. Now, scroll down to the `Pipeline` section, and repeat the procedure as specified in the shell scripts one:
	- Here, select `Pipeline script from SCM` under `Definition`.
	- Select `Git` as your `SCM` provider.
	- Under `Repository URL`, give this repository's URL.
	- You again, don't need to select any credentials, as this is a public repository.
	- Now, under branches to build, change `*/master` to `*/main`, since our repository uses the `main` branch as it's `HEAD`.
	- Under `Script Path`, specify `example-app-pipeline/Jenkinsfile`, since our `Jenkinsfile` for running these scripts is located in the `example-app-pipeline` folder.
6. Click on the `Save` button.
7. Now, click on the `Build with Parameters` button on the sidebar, and select the one and only, `origin/main` branch from the menu. In future, if your project has multiple branches, this menu will be populated with all of them, and you can build from a specific branch, for example, a branch which has a feature being worked on.
8. Click on the `Build` button, now sit back and relax, as this might take a few minutes as Jenkins has to setup everything. You can view the console output by clicking the `#1` > `Console Output`.
9. Now, if everything goes well, the console output should print `Hello World!`, right before the `post` section begins. Which means the build was successful 🎉

That's it, this simple guide, although a long journey, must've taught you a lot of things about how jenkins works, this took me a while to configure and write, but I am happy how the end results came out 😁

### Misc

This repository also contains a script, other than the Jenkins Installer `jenkins.sh`, that script would be `backup.sh`. It is a super simple files and folders backup script.

![Image](assets/9.png)

- This script is mainly used to specify a folder, and create a tar.gz archive of that folder. It even stores logs in a logfile, inside the same directory.
- You can add exclusions, such as `node_modules` while backing up a javascript project, which will exclude node modules while creating the archive.


With that, we come to the end of this file, and this tutorial. I hope you found it helpful and informative, thank you!