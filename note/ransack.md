# ransack

```ruby
s = Search.new(Person,
          g: [
            { m: 'or', name_eq: 'Ernie', children_name_eq: 'Ernie' },
            { m: 'or', name_eq: 'Bert', children_name_eq: 'Bert' },
          ]
        )
ors = s.groupings
```
