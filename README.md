![Unsupported](https://img.shields.io/badge/development_status-in_progress-green.svg)
[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)

```

            :::.    :::.:::::::-.      ::::::::::::   ...
            `;;;;,  `;;; ;;,   `';,    ;;;;;;;;''''.;;;;;;;.
              [[[[[. '[[ `[[     [[         [[    ,[[     \[[,
              $$$ "Y$c$$  $$,    $$         $$    $$$,     $$$
              888    Y88  888_,o8P'         88,   "888,_ _,88P
              MMM     YM  MMMMP"`           MMM     "YMMMMMP"


             .::::::.  :::      :::.       .,-:::::  :::  .
            ;;;`    `  ;;;      ;;`;;    ,;;;'````'  ;;; .;;,.
            '[==/[[[[, [[[     ,[[ '[[,  [[[         [[[[[/'
              '''    $ $$'    c$$$cc$$$c $$$        _$$$$,
             88b    dPo88oo,.__888   888,`88bo,__,o,"888"88o,
              "YMmMY" """"YUMMMYMM   ""`   "YUMMMMMP"MMM "MMP"

```

nd-to-slack.sh
====

    A script that will display your navidrome users activities in slack.
    The messages will be formatted:
    "<USER> is listening to <SONG> by <ARTIST> off of <ALBUM>."

ScreenShots
----
- In Slack:
![slack](images/slack.png)
- In Wee-slack:
![wee-slack](images/weeslack.png)

Configuration
----
Before this script can be used you need to copy the
nd-to-slack.config.EXAMPLE file and copy it to nd-to-slack.config
and change all values listed as "<CHANGE ME>" to working values.

Let us start with USER, TOKEN, and SALT.
On your navidrome server (this was done with Firefox), once on your
navidrome home page, right click, and inspect. In the inspection pane click
storage at the top and then local storage on the left hand to have a window
similar to the one below:

![inspector](images/inspector.png)

- Copy the role / name value to USER.
- Copy the subsonic-salt value to SALT.
- Copy the subsonic-token value to TOKEN.

Now, lets change the server address to whatever your servers URL is.

The slack URL_API and the URL_HOOK have been covered in many other places.
You just need to add an app to slack and grab the webhook url. Once grabbed
here is the breakdown:
<pre><code>
https://hooks.slack.com/services/TTTTTTTTTTT/QQQQQQQQQQQ/XXXXXXXXXXXXXXXXXXXXXXX
|           URL_API             |                URL_HOOK                      |

</code></pre>

Once all the Vars are changed now the script can be started. That will be
covered in usage.


Usage
----
This script can be run a couple of different ways. Two of the easiest are
by using either cron or doing a while loop at the command line.

- while loop approach
<pre><code>while :; do ./nd-to-slack.sh ; sleep 300 ; done</code></pre>

- crontab approach
<pre><code>*/5 * * * * /path/to/nd-to-slack.sh >/dev/null</code></pre>

Requirements
----

- Navidrome - music server (https://www.navidrome.org/)
- JQ - JSON Processor (https://github.com/jqlang/jq)
- cURL - (https://curl.se/)
- slack - Web-based instant messaging service (https://slack.com/)


License and Author
----

Copyright (c) 2024, cesar@poa.nyc
All rights reserved.

This source code is licensed under the Unlicense
found in the LICENSE file in the root directory of this
source tree.
