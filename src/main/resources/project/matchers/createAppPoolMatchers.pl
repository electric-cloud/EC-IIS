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
   id =>        "appPoolCreated",
   pattern =>          q{Application Pool (.+) created successfully},
   action =>           q{
    
              my $description = "Application Pool $1 created successfully";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  {
   id =>        "appPoolExists",
   pattern =>          q{^183$},
   action =>           q{
    
              #183: error code for existent name at desired location
              my $description = "The specified Application Pool already exists, choose a different name and try again.";
              
              setProperty("summary", $description . "\n");
    
   },
  },
  
  
  
 
);

