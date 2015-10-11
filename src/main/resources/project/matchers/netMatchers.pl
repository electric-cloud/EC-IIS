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
   id =>        "serviceStartedOk",
   pattern =>          q{The(.*)started successfully(.*)},
   action =>           q{
    
              my $description = ((defined $::gProperties{"summary"}) ? 
                    $::gProperties{"summary"} : '');
                    
              $description .= "$1 started successfully";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  {
   id =>        "serviceStoppedOk",
   pattern =>          q{(.*)stopped successfully(.*)},
   action =>           q{
    
              my $description = ((defined $::gProperties{"summary"}) ? 
                    $::gProperties{"summary"} : '');
                    
              $description .= "$1 stopped successfully";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
  {
   id =>        "servicesStarted",
   pattern =>          q{(Successfully started .+)},
   action =>           q{
    
              my $description = "$1";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
  {
   id =>        "servicesStopped",
   pattern =>          q{(Successfully stopped .+)},
   action =>           q{
    
              my $description = "$1";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
);

