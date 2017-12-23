Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

{ listenForTranslations, performTranslation } = require 'angular/helpers/translation.coffee'
{ listenForReactions } = require 'angular/helpers/emoji.coffee'
{ scrollTo }           = require 'angular/helpers/window.coffee'

angular.module('loomioApp').directive 'contextPanel', ($rootScope, $translate, ModalService, ThreadService) ->
  scope: {discussion: '='}
  restrict: 'E'
  replace: true
  templateUrl: 'generated/components/thread_page/context_panel/context_panel.html'
  controller: ($scope) ->

    $scope.status = ->
      return 'pinned' if $scope.discussion.pinned

    $scope.statusTitle = ->
      $translate.instant "context_panel.thread_status.#{$scope.status()}"

    $scope.showLintel = (bool) ->
      $rootScope.$broadcast('showThreadLintel', bool)

    $scope.showRevisionHistory = ->
      ModalService.open 'RevisionHistoryModal', model: => $scope.discussion

    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canAddComment($scope.discussion)
    ,
      name: 'edit_thread'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditThread($scope.discussion)
      perform:    -> ModalService.open 'DiscussionModal', discussion: -> $scope.discussion
    ,
      name: 'add_resource'
      icon: 'mdi-attachment'
      canPerform: -> AbilityService.canAdministerDiscussion($scope.discussion)
      perform:    -> ModalService.open 'DocumentModal', doc: ->
        Records.documents.build
          modelId:   $scope.discussion.id
          modelType: 'Discussion'
    ,
      name: 'translate_thread'
      icon: 'mdi-translate'
      canPerform: -> AbilityService.canTranslate($scope.discussion) && !$scope.translation
      perform:    -> performTranslation($scope, $scope.discussion)
    ,
      name: 'add_comment'
      icon: 'mdi-reply'
      canPerform: -> AbilityService.canAddComment($scope.discussion)
      perform:    -> scrollTo('.comment-form textarea')
    ,
      name: 'pin_thread'
      icon: 'mdi-pin'
      canPerform: -> AbilityService.canPinThread($scope.discussion)
      perform:    -> ThreadService.pin($scope.discussion)
    ,
      name: 'unpin_thread'
      icon: 'mdi-pin-off'
      canPerform: -> AbilityService.canUnpinThread($scope.discussion)
      perform:    -> ThreadService.unpin($scope.discussion)
    ]

    listenForTranslations($scope)
    listenForReactions($scope, $scope.discussion)