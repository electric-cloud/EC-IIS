
push (@::gMatchers,
  {
   id =>        "appPoolStarted",
   pattern =>          q{Application Pool (.+) started successfully},
   action =>           q{
    
              my $description = "Application Pool $1 started successfully";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
  
  
 
);

