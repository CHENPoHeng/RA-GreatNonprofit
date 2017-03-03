1. Data Collection
    - source: greatnonprofits.org
    - data:
        - all states
        - all organization data
        - all reviews under each organization
    - format: tsv file format to save storage

2. Preliminary Analysis
    - Per state: 
        - what is the fraction of charity organizations that reside in a given state (if there were 1000 orgs in total and 13 of them were in Alabama, the number of Alabama would be 1.3%)
        - what is the fraction of reviews come from an org in a given state (if there were 1000 reviews in total and 13 of them were from an org in Alabama, the number of Alabama would be 1.3%)
        - what is the fraction of reviews are of a certain kind in a given state (if there were 1000 reviews for orgs in Alabama and 13 of them came from "General Member of the Public" , the number for "General Member of the Public" for Alabama would be 1.3%) - we would a column per type.
    - Per org: 
        - how many reviews does an org have? We can create PDF and CDF plots (x axis: number of reviews, y axis: number of charities that have that many reviews) in linear and log-scale
        - what fraction of reviews come from a certain kind (e.g.  "General Member of the Public"). Again a CDF (x axis: fraction of reviews from  "General Member of the Public", y-axis: fraction of orgs that have that fraction for that type). We can have a curve per type.
    - Per user:
        - how many reviews do a user write? We can create PDF and CDF plots (x axis: number of reviews, y axis: number of reviewers that write that many reviews) in linear and log-scale
        - what fraction of reviews written by an individual are in a certain role (e.g. "General Member of the Public") Again a CDF (x axis: fraction of reviews written as a  "General Member of the Public", y-axis: fraction of users that have written at least that fraction of their reviews in that role). We can have a curve per type again.