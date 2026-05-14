using {com.mycompany.leads as db} from '../db/schema';

service ProductService {

    // ─── EXPOSE entity
    @Aggregation.RecursiveHierarchy #ProductsHierarchy: {
        // Tells OData V4: "ID ithes the node key, parent is  link"
        NodeProperty             : ID,
        ParentNavigationProperty : parent 
        // parent → the Association to Products in schema.cds
    }

    @Hierarchy.RecursiveHierarchy #ProductsHierarchy: {
        // Tell UI5: which fields drive the visual tree rendering
        ExternalKey           : ID,
        LimitedDescendantCount: LimitedDescendantCount,
        DistanceFromRoot      : DistanceFromRoot,
        DrillState            : DrillState,
        Matched               : Matched,
        MatchedDescendantCount: MatchedDescendantCount
    }

    entity Products as projection on db.Products {
        *     // all fields from schema
    }
}