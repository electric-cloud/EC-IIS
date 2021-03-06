
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

