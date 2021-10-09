xquery version "3.1";

module namespace edf="http://trustthevote.org/modules/edf";
import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace lib="http://exist-db.org/xquery/html-templating/lib";
import module namespace config="http://trustthevote.org/apps/ere/config" at "config.xqm";

declare namespace er="NIST_V1_election_results.xsd";
declare namespace xsi="http://www.w3.org/2001/XMLSchema-instance";

declare function edf:ElectionScopeIds($node as node(), $model as map(*)) as element()* {
    collection($config:data-root)//er:ElectionScopeId
};

declare function edf:ReportingUnitIds($node as node(), $model as map(*)) {
    let $reporting-units := collection($config:data-root)//er:GpUnit[@xsi:type="ReportingUnit"]
    return
        map:merge(
            for $type in distinct-values($reporting-units/er:Type)
            return map:entry(string($type), $reporting-units[./er:Type=$type]))
};

declare 
    %templates:wrap
function edf:cities($node as node(), $model as map(*)) {
    let $reporting-map := edf:ReportingUnitIds($node, $map)
     return map { "cities" : $reporting-map }
};

declare 
    %templates:wrap
function edf:city-list($node as node(), $model as map(*)) {
    let $cities := $model("cities")
    return $cites
};