(*functional-properties* '(rdf:type))

(*unique-variables* '(?session ?user))

(define-constraint  
  'read/write 
  (lambda ()    "
PREFIX graphs: <http://mu.semte.ch/school/graphs/>
PREFIX school: <http://mu.semte.ch/vocabularies/school/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

CONSTRUCT {
  ?a ?b ?c
}
WHERE {
  GRAPH <http://mu.semte.ch/authorization> {
    ?session mu:uuid <SESSION_ID>;
             mu:account ?user.
  }

  {
    @access Type(?type)
    FILTER ( ?type != school:Grade )
    GRAPH ?graph { 
      ?a ?b ?c;
         a ?type
    }
  }
  UNION {
    @access Grade
    FILTER ( ?type = school:Grade )
    GRAPH ?graph { 
      ?a ?b ?c;
         a ?type;
    }

    { 
      GRAPH graphs:people { ?user school:role \"principle\" }
    }
    UNION {
      GRAPH graphs:people { ?user school:role \"teacher\" }
      GRAPH graphs:classes {
        ?class school:hasTeacher ?user;
               school:classGrade ?a
      }
    }
    UNION {
      GRAPH graphs:people { ?user school:role \"student\" }
      GRAPH graphs:grades { ?a school:gradeRecipient ?user }
    }
  }
  VALUES (?graph ?type) {
    (graphs:grades school:Grade)
    (graphs:subjects school:Subject) 
    (graphs:classes school:Class) 
    (graphs:people foaf:Person) 
  }
}  "))
