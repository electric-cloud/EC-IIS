#
#  Copyright 2015 Electric Cloud, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#


push (@::gMatchers,
  {
   id =>        "sitePaused",
   pattern =>          q{Server (.+) Paused},
   action =>           q{
    
              my $description = "Server $1 Paused";
              setProperty("summary", $description . "\n");
    
   },
  },
  
  {
   id =>        "siteNotFound",
   pattern =>          q{Server (.+) was not found},
   action =>           q{
    
              my $description = "Server $1 was not found";
              setProperty("summary", $description . "\n");
    
   },
  },
  
  {
   id =>        "hostNotFound",
   pattern =>          q{(Host (.+) was not found|The remote server machine does not exist or is unavailable)},
   action =>           q{
    
              my $description = "Host $1 was not found";
              setProperty("summary", $description . "\n");
    
   },
  },
  
  {
   id =>        "remoteServerDoesntExists",
   pattern =>          q{(The remote server machine does not exist or is unavailable)},
   action =>           q{
    
              my $description = "$1";
              setProperty("summary", $description . "\n");
    
   },
  },
);

