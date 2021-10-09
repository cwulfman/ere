xquery version "3.1";

(:~ This library module contains XQSuite tests for the ere app.
 :
 : @author cwulfman
 : @version 1.0.0
 : @see http://cwulfman.org
 :)

module namespace tests = "http://trustthevote.org/apps/ere/tests";

import module namespace app = "http://trustthevote.org/apps/ere/templates" at "../../modules/app.xql";
 
declare namespace test="http://exist-db.org/xquery/xqsuite";


declare variable $tests:map := map {1: 1};

declare
    %test:name('dummy-templating-call')
    %test:arg('n', 'div')
    %test:assertEquals("<p>Dummy templating function.</p>")
    function tests:templating-foo($n as xs:string) as node(){
        app:foo(element {$n} {}, $tests:map)
};
