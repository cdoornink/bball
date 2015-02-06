`import DS from 'ember-data'`
`import ENV from '../config/environment';`

ApplicationAdapter = DS.FirebaseAdapter.extend
	firebase: new Firebase(ENV.firebaseURL)

`export default ApplicationAdapter`
