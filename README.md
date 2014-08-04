# Mdmap

A tool for collection, matching, and generation of bibliographic metadata.

## Getting started

Install rails

Then:

    bundle install
    rake db:migrate
    rails s

Create a *config/config.yml* file in your application. Add your (institution's) WSKey (https://oclc.org/developer/develop/authentication/what-is-a-wskey.en.html):

<pre>
wskey: yourKey
</pre>  

 

## License

Copyright 2014 Rico Simke, Leipzig University Library

http://www.ub.uni-leipzig.de

This code the result of the project "Die Bibliothek der Milliarden Wörter".
This project is funded by the European Social Fund. "Die Bibliothek der
Milliarden Wörter" is a cooperation project between the Leipzig University
Library, the Natural Language Processing Group at the Institute of Computer
Science at Leipzig University, and the Image and Signal Processing Group
at the Institute of Computer Science at Leipzig University.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.