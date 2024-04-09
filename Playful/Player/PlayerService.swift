//
//  Player.swift
//  Playful
//
//  Created by Pfriedrix on 08.04.2024.
//

import AVFoundation
import ComposableArchitecture
import Combine

final class PlayerService {
    private var cancellable = Set<AnyCancellable>()
    
    private let session = AVAudioSession.sharedInstance()
    private let player = AVPlayer()
    
    private let viewStore: StoreOf<ViewPlayer>
    
    init(viewStore: StoreOf<ViewPlayer>) {
        self.viewStore = viewStore
        
        bind()
        bindObservers()
        
        try? session.setCategory(.playback, options: [.mixWithOthers, .allowAirPlay, .allowBluetooth])
    }
    
    private func bind() {
        viewStore.publisher.control
            .sink { [ weak self ] action in
                guard let action = action else { return }
                switch action {
                case let .load(with: url):
                    let asset = AVURLAsset(url: url)
                    let item = AVPlayerItem(asset: asset)
                    self?.player.replaceCurrentItem(with: item)
                case .play:
                    self?.player.play()
                case .pause:
                    self?.player.pause()
                case let .seek(to: time):
                    self?.player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
                default: break
                }
            }
            .store(in: &cancellable)
    }
    
    private func bindObservers() {
        player.publisher(for: \.status)
            .sink { [ weak self ] in self?.viewStore.send(.player(.status($0))) }
            .store(in: &cancellable)
        
        player.publisher(for: \.timeControlStatus)
            .sink { 
                [ weak self ] in self?.viewStore.send(.player(.timeControlStatus($0)))
            }
            .store(in: &cancellable)
        
        player.publisher(for: \.reasonForWaitingToPlay)
            .sink { [ weak self ] in self?.viewStore.send(.player(.reasonForWaitingToPlay($0))) }
            .store(in: &cancellable)
        
        player.publisher(for: \.rate)
            .sink { [ weak self ] in self?.viewStore.send(.player(.rate($0))) }
            .store(in: &cancellable)
        
        player.publisher(for: \.volume)
            .sink { [ weak self ] in self?.viewStore.send(.player(.volume($0))) }
            .store(in: &cancellable)
        
        player.publisher(for: \.currentItem)
            .sink { [ weak self ] in self?.viewStore.send(.playerItem($0)) }
            .store(in: &cancellable)
        
        player.addPeriodicTimeObserver(forInterval: .init(value: 1, timescale: 1), queue: .main) { [ weak self ] in
            self?.viewStore.send(.player(.currentTime($0)))
        }
    }
}
