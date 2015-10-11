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
   id =>        "siteNotFound",
   pattern =>          q{(Site\(s\) not found)},
   action =>           q{
    
              my $description = "$1";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
  {
   id =>        "createWebsite",
   pattern =>          q{(Status(\s+)=(\s+)STOPPED|Status(\s+)=(\s+)STARTED)},
   action =>           q{
    
              my $description = "Website successfully created.";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
 {
   id =>        "createVDir",
   pattern =>          q{Virtual Path  = (.+)},
   action =>           q{
    
              my $description = "Virtual directory successfully created at $1.";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
  {
   id =>        "vdirNameExistsError",
   pattern =>          q{The virtual directory (.+) already exists},
   action =>           q{
    
              my $description = "Virtual directory at $1 already exists. Try a different name.";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
  {
   id =>        "pauseWebsite",
   pattern =>          q{Server (.+) has been PAUSED},
   action =>           q{
    
              my $description = "Server $1 has been successfully paused";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
  {
   id =>        "websiteContinued",
   pattern =>          q{Server (.+) has been CONTINUED},
   action =>           q{
    
              my $description = "Server $1 has been successfully continued";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
    {
   id =>        "websiteStopped",
   pattern =>          q{Server (.+) has been STOPPED},
   action =>           q{
    
              my $description = "Server $1 has been successfully stopped";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
  {
   id =>        "serverCannotBeStopped",
   pattern =>          q{Server cannot be stopped in its current state},
   action =>           q{
    
              my $description = "$1";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
  {
   id =>        "vdirDoesntExist",
   pattern =>          q{The virtual directory (.+) does not exist},
   action =>           q{
    
              my $description = "The virtual directory $1 does not exist";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
  {
   id =>        "vdirDeleted",
   pattern =>          q{Web directory (.+) has been DELETED},
   action =>           q{
    
              my $description = "The virtual directory $1 has been successfully deleted";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
  {
   id =>        "siteDeleted",
   pattern =>          q{Server (.+) has been deleted},
   action =>           q{
    
              my $description = "Website $1 successfully deleted";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
 
);

