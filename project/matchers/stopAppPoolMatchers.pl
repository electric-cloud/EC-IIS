
push (@::gMatchers,
  {
   id =>        "appPoolStopped",
   pattern =>          q{Application Pool (.+) stopped successfully},
   action =>           q{
    
              my $description = "Application Pool $1 stopped successfully";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  
  
  
 
);

