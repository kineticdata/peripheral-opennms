# OpenNMS Notification Consumer

## OpenNMS Configuration

First you will need to define a new notification command in OpenNMS like this:

```
<command binary="false">
  <name>kdTaskSend</name>
  <execute>org.opennms.netmgt.notifd.HttpNotificationStrategy</execute>
  <comment>Class for sending notifications with an HTTP Post</comment>
  <argument streamed="false">
    <switch>url</switch>
  </argument>
  <argument streamed="false">
    <switch>timeout</switch>
  </argument>
  <argument streamed="false">
    <switch>retries</switch>
  </argument>
  <argument streamed="false">
    <switch>-tm</switch>
  </argument>
  <argument streamed="false">
    <switch>post-nodeid</switch>
  </argument>
  <argument streamed="false">
    <switch>post-message</switch>
  </argument>
</command>
```

The notification will need a destination path. Creating a destination path is straight forward. Create a new one, choose kdTaskSend as the command and you can use any user as the destination as the user will be ignored. It's typically best to use an admin user so notifications don't appear on users consoles.

It's very important that you force _autoNotify_ to _off_ in the destination path. This is important because if _autoNotify_ is on OpenNMS will send resolution notifications to Kinetic Task using this notification path and Kinetic Task will have no way to know that this is a resolution notification. Resolutions should be handled through an additional path targeting the _uei.opennms.org/nodes/nodeUp_ event.

Here is an example _destinationPaths.xml_ file:

```
<path name="KineticTask">
  <target>
    <name>Admin</name>
    <autoNotify>off</autoNotify>
    <command>kdTaskSend</command>
  </target>
</path>
```

You will also need to define a notification (to define what is sent), and a destination path
which uses the `kdTaskSend` notification command. The notification is easiest configured in XML and
not in the Web UI. Here is an example notification:

```
<notification name="kdTaskSend" status="on" writeable="yes">
  <uei>uei.opennms.org/nodes/nodeDown</uei>
  <rule>(IPADDR IPLIKE *.*.*.*)</rule>
  <destinationPath>KineticTask</destinationPath>
  <text-message>All services are down on node %nodeid%</text-message>
  <subject>node: %nodeid% down</subject>
  <parameter name="url" value="http://localhost:8080/kinetic-task/app/api/v1/run-tree/OpenNMS/NodeDown/Create"/>
  <parameter name="timeout" value="2000"/>
  <parameter name="retries" value="1"/>
  <parameter name="post-nodeid" value="%nodeid%" />
  <parameter name="post-nodelabel" value="%nodelabel%" />
  <parameter name="post-noticeid" value="%noticeid%" />
  <parameter name="post-eventid" value="%eventid%" />
  <parameter name="post-timesent" value="%time%" />
  <parameter name="post-severity" value="%severity%" />
  <parameter name="post-message" value="All services are down on node %nodeid%" />
</notification>
```

### Simulating OpenNMS Notifications.

The OpenNMS HTTP Notification Strategy sends the _post-_ arguments as POST query parameters.

You can easily simulate the notification defined above using cURL:

```
curl -X POST "http://kinetictask/kinetic-task/app/api/v1/run-tree/OpenNMS/NodeDown/Create?nodeid=1&message=All+services+are+down+on+node+1"
```

Be sure to include other fields if they're necessary to your Task workflow.
