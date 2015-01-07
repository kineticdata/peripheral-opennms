# OpenNMS Notification Consumer

## OpenNMS Configuration

You will need to define a new notification command in OpenNMS like this:

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
  <parameter name="url" value="http://kinetictask/kinetic-task/app/api/v1/run-tree/OpenNMS/NodeDown/Create"/>
  <parameter name="timeout" value="2000"/>
  <parameter name="retries" value="1"/>
  <parameter name="post-nodeid" value="%nodeid%"/>
  <parameter name="post-message" value="All services are down on node %nodeid%"/>
</notification>
```

### Simulating OpenNMS Notifications.

The OpenNMS HTTP Notification Strategy sends the _post-_ arguments as POST query parameters.

You can easily simulate the notification defined above using cURL:

```
curl -X POST "http://kinetictask/kinetic-task/app/api/v1/run-tree/OpenNMS/NodeDown/Create?nodeid=1&message=All+services+are+down+on+node+1"
```
