<index>
{
let $index := doc("index.xml")
let $keys := distinct-values(for $item in $index//entry
                              order by $item/id
                              return data($item/id))
for $id in $keys
 return <entry><id>{$id}</id>
   <items>{
   let $types := sort(distinct-values($index//entry[id = $id]/type))
    for $t in $types
     return <item><type>{$t}</type>
     <page>{
      string-join(
        sort(distinct-values($index//entry[id = $id and type = $t]/page)),
        ', ')
     }</page></item>
   }</items>
   </entry>
}
</index>
