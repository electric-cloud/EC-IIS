
push (@::gMatchers,
  {
   id =>        "appCreated",
   pattern =>          q{Web Application (.+) created},
   action =>           q{
    
              my $description = "Web Application $1 created";
              setProperty("summary", $description . "\n");
    
   },
  },
 
);

