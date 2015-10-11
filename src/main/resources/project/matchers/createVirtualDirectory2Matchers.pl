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
   id =>        "vdirExists",
   pattern =>          q{.*-2147024713.*},
   action =>           q{
    
              my $description = "The virtual directory ID already exists in the WebSite.";
              setProperty("summary", $description . "\n");
    
   },
  },
  
  {
   id =>        "vdirCreated",
   pattern =>          q{Virtual directory (.+) successfully created},
   action =>           q{
    
              my $description = "$1 successfully created";
              setProperty("summary", $description . "\n");
    
   },
  },
 
);

