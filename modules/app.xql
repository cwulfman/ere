xquery version "3.1";

(:~ This is the default application library module of the ere app.
 :
 : @author cwulfman
 : @version 1.0.0
 : @see http://cwulfman.org
 :)

(: Module for app-specific template functions :)
module namespace app="http://trustthevote.org/apps/ere/templates";
import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace lib="http://exist-db.org/xquery/html-templating/lib";
import module namespace config="http://trustthevote.org/apps/ere/config" at "config.xqm";

declare namespace er="NIST_V1_election_results.xsd";
declare namespace xsi="http://www.w3.org/2001/XMLSchema-instance";

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute: data-template="app:test" or class="app:test" (deprecated).
 : The function has to take 2 default parameters. Additional parameters are automatically mapped to
 : any matching request or function parameter.
 :
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)

declare
    %templates:wrap
function app:foo($node as node(), $model as map(*)) {
    <p>Dummy templating function.</p>
};

declare function app:test($node as node(), $model as map(*)) {
    <p>Dummy template output generated by function app:test at {current-dateTime()}. The templating
        function was triggered by the class attribute <code>class="app:test"</code>.</p>
};

declare function app:stats($node as node(), $model as map(*)) {
    <table class="table table-bordered">
        <caption>Collection Stats</caption>
        <tr>
            <td>number of elections:</td>
            <td>{count(app:ElectionScopeIds($node, $model))}</td>
        </tr>
        <tr>
            <td>number of reporting units:</td>
            <td>
                <dl class="row"> {
            let $id-map := app:ReportingUnitIds($node, $model)
            return map:for-each($id-map, function($k, $v) { <dt class="col-sm-9">{$k}</dt>,<dd class="col-sm-3">{count($v)}</dd> } )
            }</dl>
            </td>
        </tr>
    </table>
};


declare function app:ElectionScopeIds($node as node(), $model as map(*)) as element()* {
    collection($config:data-root)//er:ElectionScopeId
};

declare function app:ReportingUnitIds($node as node(), $model as map(*)) {
    let $reporting-units := collection($config:data-root)//er:GpUnit[@xsi:type="ReportingUnit"]
    return
        map:merge(
            for $type in distinct-values($reporting-units/er:Type)
            return map:entry(string($type), $reporting-units[./er:Type=$type]))
};

declare function app:cities($node as node(), $model as map(*)) {
    let $city-reporting-units := collection($config:data-root)//er:GpUnit[@xsi:type="ReportingUnit" and er:Type="city"]
    return map { 'cities' : $city-reporting-units }
};

declare 
    %templates:wrap
function app:city-list($node as node(), $model as map(*)) {
    for $unit in $model('cities')
    return
    <li>{ $unit/er:Name/text() }</li>
};

declare function app:gpunit($node as node(), $model as map(*), $id as xs:string) {
    let $unit := collection($config:data-root)//er:GpUnit[@objectId = $id]
    return map { 'current-gpunit' : $unit }
};

declare function app:gpunit-title($node as node(), $model as map(*)) {
    <header>
        <h2>{ $model('current-gpunit')/er:Name/text() }</h2>
    </header>
};

declare function app:gpunit-info($node as node(), $model as map(*)) {
    let $unit := $model('current-gpunit')
    let $type := $unit/er:Type/text()
    return $type
};


declare 
    %templates:wrap
function app:gpunit-contests($node as node(), $model as map(*)) {
    let $unit := $model('current-gpunit')
    let $contests := $unit/ancestor::er:ElectionReport//er:Contest[er:ElectoralDistrictId = $unit/@objectId]
    for $contest in $contests
    return <li><a href="contests.html?id={$contest/@objectId}">{ $contest/er:Name/text() }</a></li>
};

declare 
   %templates:wrap
function app:gpunit-composing-units($node as node(), $model as map(*)) {
    let $unit := $model('current-gpunit')
    let $electionReport := $unit/ancestor::er:ElectionReport
    let $precinctids := $unit/er:ComposingGpUnitIds
    for $precinctid in tokenize($precinctids)
        let $precinct := $electionReport//er:GpUnit[@objectId=xs:string($precinctid)]
        return <tr>
        <td>{ $precinct/er:Name/text() }</td>
        <td>{ $precinct/er:Type/text() }</td>
        </tr>
};
