import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getObjectivesByUserAndYear from '@salesforce/apex/ObjectiveController.getObjectivesByUserAndYear';
import createObjective from '@salesforce/apex/ObjectiveController.createObjective';
import getUsers from '@salesforce/apex/UserController.getUsers';
import getNearest10Years from '@salesforce/apex/ObjectiveController.getNearest10Years';
import getRelatedRecords from '@salesforce/apex/RelatedRecordController.getRelatedRecords';
import createRelatedRecord from '@salesforce/apex/RelatedRecordController.createRelatedRecord';
import getKeyResultsWithTargets from '@salesforce/apex/KeyResultController.getKeyResultsWithTargets';
import createKeyResult from '@salesforce/apex/KeyResultController.createKeyResult';
import saveNewTarget from '@salesforce/apex/KeyResultController.saveNewTarget';

export default class Okrdashboard extends LightningElement {
    // Tracked properties for reactive state management
    @track objectives;
    @track isModalOpen = false;
    @track objectiveName = '';
    @track selectedUserId;
    @track selectedYear;
    @track userOptions = [];
    @track yearOptions = [];
    @track isNewKeyResultModalOpen = false;
    @track newKeyResultName = '';
    @track selectedObjectiveId;
    @track isRelatedRecordsModalOpen = false;
    @track relatedRecords;
    @track selectedKeyResultId;
    @track isNewRelatedRecordModalOpen = false;
    @track relatedRecordName = '';
    @track relatedRecordType = '';
    @track relatedRecordTypeOptions = [
        { label: 'Survey', value: 'Survey' },
        { label: 'Review', value: 'Review' },
        { label: 'Google Review', value: 'Google Review' },
        { label: 'Case Study', value: 'Case Study' },
        { label: 'Call', value: 'Call' },
        { label: 'Event', value: 'Event' },
        { label: 'Lead', value: 'Lead' },
        { label: 'Opportunity', value: 'Opportunity' },
        { label: 'Contract', value: 'Contract' }
    ];
    @track selectedTargets = [];
    @track targetScore;
    @track isNewTargetModalOpen = false;
    @track currentKeyResultId;
    @track additionalOptions = [];

    targetOptions = [
        { label: 'Calls', value: 'Calls' },
        { label: 'Case Studies', value: 'Case Studies' },
        { label: 'Contracts', value: 'Contracts' },
        { label: 'Events', value: 'Events' },
        { label: 'Google Reviews', value: 'Google Reviews' },
        { label: 'Leads', value: 'Leads' },
        { label: 'Opportunities', value: 'Opportunities' },
        { label: 'Reviews', value: 'Reviews' },
        { label: 'Surveys', value: 'Surveys' }
    ];

    eventOptions = [
        { label: 'Email', value: 'Email' },
        { label: 'Meeting', value: 'Meeting' },
        { label: 'Other', value: 'Other' },
    ];

    contractOptions = [
        { label: 'Silver', value: 'Silver' },
        { label: 'Gold', value: 'Gold' },
        { label: 'Platinum', value: 'Platinum' }
    ];
    
    //Lifecycle hook called when the component is inserted into the DOM.
    connectedCallback() {
        this.loadInitialData();
    }

    //Loads initial data (users and years).
    loadInitialData() {
        this.loadUsers();
        this.loadYears();
    }

    //Fetches users and sets the default user.
    loadUsers() {
        getUsers().then(data => {
            this.userOptions = data.map(user => ({
                label: user.Name,
                value: user.Id
            }));
            this.selectedUserId = data[0]?.Id; // Default to the first user
            this.loadObjectives();
        }).catch(error => {
            console.error(error);
        });
    }

    //Fetches the nearest 10 years and sets the default year.
    loadYears() {
        getNearest10Years().then(data => {
            this.yearOptions = data.map(year => ({
                label: year,
                value: year
            }));
            this.selectedYear = this.yearOptions[0]?.value; // Default to the first year
            this.loadObjectives();
        }).catch(error => {
            console.error(error);
        });
    }

    //Fetches objectives for the selected user and year.
    async loadObjectives() {
        if (this.selectedUserId && this.selectedYear) {
            try {
                const data = await getObjectivesByUserAndYear({ userId: this.selectedUserId, year: this.selectedYear });
                const objectivesWithKeyResultsPromises = data.map(async (obj) => {
                    try {
                        const keyResults = await getKeyResultsWithTargets({ objectiveId: obj.id });
                        return { ...obj, keyResults: keyResults, showKeyResults: false };
                    } catch (error) {
                        console.error(`Error fetching key results for objective ${obj.id}:`, error);
                        return { ...obj, keyResults: [], showKeyResults: false };
                    }
                });

                const objectivesWithKeyResults = await Promise.all(objectivesWithKeyResultsPromises);
                this.objectives = objectivesWithKeyResults;
            } catch (error) {
                console.error('Error loading objectives:', error);
            }
        }
    }

    handleUserSelectionChange(event) {
        this.selectedUserId = event.detail.value;
        this.loadObjectives();
    }

    handleYearSelectionChange(event) {
        this.selectedYear = event.detail.value;
        this.loadObjectives();
    }

    handleInputChange(event) {
        const field = event.target.dataset.id;
        if (field === 'name') {
            this.objectiveName = event.target.value;
        } else if (field === 'year') {
            this.selectedYear = event.target.value;
        } else if (field === 'user') {
            this.selectedUserId = event.target.value;
        }
    }

    handleShowModal() {
        this.isModalOpen = true;
    }

    handleCloseModal() {
        this.isModalOpen = false;
    }

    handleSave() {
        createObjective({
            name: this.objectiveName,
            year: this.selectedYear,
            userId: this.selectedUserId
        })
        .then(() => {
            this.isModalOpen = false;
            this.showToast('Success', 'Objective created successfully', 'success');
            this.loadObjectives();
        })
        .catch(error => {
            console.error(error);
            this.showToast('Error', 'Error creating objective', 'error');
        });
    }

    handleShowNewKeyResultModal(event) {
        this.selectedObjectiveId = event.target.dataset.objectiveId;
        this.isNewKeyResultModalOpen = true;
    }

    handleCloseNewKeyResultModal() {
        this.isNewKeyResultModalOpen = false;
    }

    handleNewKeyResultNameChange(event) {
        this.newKeyResultName = event.target.value;
    }

    handleSaveNewKeyResult() {
        createKeyResult({
            objectiveId: this.selectedObjectiveId,
            name: this.newKeyResultName
        })
        .then(() => {
            this.isNewKeyResultModalOpen = false;
            this.showToast('Success', 'Key Result created successfully', 'success');
            return getKeyResultsWithTargets({ objectiveId: this.selectedObjectiveId });
        })
        .then(result => {
            const updatedObjectives = this.objectives.map(obj => {
                if (obj.id === this.selectedObjectiveId) {
                    return { ...obj, keyResults: result };
                }
                return obj;
            });
            this.objectives = updatedObjectives;
        })
        .catch(error => {
            console.error(error);
            this.showToast('Error', 'Error creating key result', 'error');
        });
    }

    handleToggleKeyResults(event) {
        const objectiveId = event.target.dataset.id;
        this.objectives = this.objectives.map(obj => {
            if (obj.id === objectiveId) {
                return { ...obj, showKeyResults: !obj.showKeyResults };
            }
            return obj;
        });
    }    

    handleShowRelatedRecords(event) {
        this.selectedKeyResultId = event.target.dataset.id;
        getRelatedRecords({ keyResultId: this.selectedKeyResultId })
        .then(result => {
            this.relatedRecords = result;
            this.isRelatedRecordsModalOpen = true;
        })
        .catch(error => {
            console.error(error);
        });
    }

    handleCloseRelatedRecordsModal() {
        this.isRelatedRecordsModalOpen = false;
    }

    handleShowNewRelatedRecordModal(event) {
        this.selectedKeyResultId = event.target.dataset.id;
        this.isNewRelatedRecordModalOpen = true;
    }

    handleCloseNewRelatedRecordModal() {
        this.isNewRelatedRecordModalOpen = false;
    }

    handleRelatedRecordNameChange(event) {
        this.relatedRecordName = event.target.value;
    }

    handleRelatedRecordTypeChange(event) {
        this.relatedRecordType = event.detail.value;
    }

    handleSaveRelatedRecord() {

        console.log('Attempting to save related record with data:', {
            keyResultId: this.selectedKeyResultId,
            recordName: this.relatedRecordName,
            recordType: this.relatedRecordType
        });

        createRelatedRecord({
            keyResultId: this.selectedKeyResultId,
            recordName: this.relatedRecordName,
            recordType: this.relatedRecordType
        })
        .then(result => {
            this.isNewRelatedRecordModalOpen = false;
            this.showToast('Success', 'Related record created successfully', 'success');
            this.relatedRecords = [...this.relatedRecords, result];
        })
        .catch(error => {
            console.error('Error creating related record:', error);
            this.showToast('Error', 'Error creating related record', 'error');
        });
    }

    handleShowNewTargetModal(event) {
        this.currentKeyResultId = event.target.dataset.id;
        this.isNewTargetModalOpen = true;
    }

    handleCloseNewTargetModal() {
        this.isNewTargetModalOpen = false;
        this.selectedTargets = [];
        this.targetScore = null;
    }

    handleTargetSelection(event) {
        this.selectedTargets = event.detail.value;
        this.updateAdditionalOptions();
    }

    handleTargetScoreChange(event) {
        this.targetScore = event.target.value;
    }

    updateAdditionalOptions() {
        if (this.selectedTargets.includes('Events')) {
            this.additionalOptions = this.eventOptions;
        } else if (this.selectedTargets.includes('Contracts')) {
            this.additionalOptions = this.contractOptions;
        } else {
            this.additionalOptions = [];
        }
    }

    handleAdditionalOptionChange(event) {
        this.selectedAdditionalOption = event.detail.value;
    }

    handleSaveNewTarget() {

        console.log('Attempting to save new target with data:', {
            keyResultId: this.currentKeyResultId,
            targets: this.selectedTargets,
            targetScore: this.targetScore,
            additionalOption: this.selectedAdditionalOption
        });

        if (!this.selectedTargets.length || !this.targetScore) {
            this.showToast('Error', 'Please select at least one target and set a target value', 'error');
            return;
        }

        saveNewTarget({
            keyResultId: this.currentKeyResultId,
            targets: this.selectedTargets,
            targetScore: this.targetScore,
            additionalOption: this.selectedAdditionalOption
        })
        .then(() => {
            this.showToast('Success', 'Target saved successfully', 'success');
            this.selectedTargets = [];
            this.targetScore = null;
            return getKeyResultsWithTargets({ objectiveId: this.selectedObjectiveId });
        })
        .then(result => {
            const updatedObjectives = this.objectives.map(obj => {
                if (obj.id === this.selectedObjectiveId) {
                    return { ...obj, keyResults: result };
                }
                return obj;
            });
            this.objectives = updatedObjectives;
        })
        .catch(error => {
            console.error('Error saving target:', error);
            this.showToast('Error saving target', error.body.message, 'error');
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }

}