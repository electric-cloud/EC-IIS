
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

